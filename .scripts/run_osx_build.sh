#!/usr/bin/env bash

set -x

source .scripts/logging_utils.sh

( startgroup "Provisioning build tools" ) 2> /dev/null

MINIFORGE_HOME=${MINIFORGE_HOME:-${HOME}/miniforge3}
MINIFORGE_HOME=${MINIFORGE_HOME%/} # remove trailing slash
export CONDA_BLD_PATH=${CONDA_BLD_PATH:-${MINIFORGE_HOME}/conda-bld}

if [[ -f "${MINIFORGE_HOME}/conda-meta/history" ]]; then
  echo "Build tools already installed at ${MINIFORGE_HOME}."
else
  if command -v micromamba >/dev/null 2>&1; then
    micromamba_exe="micromamba"
    echo "Found micromamba in PATH"
  else
    MICROMAMBA_VERSION="1.5.10-0"
    if [[ "$(uname -m)" == "arm64" ]]; then
      osx_arch="osx-arm64"
    else
      osx_arch="osx-64"
    fi
    MICROMAMBA_URL="https://github.com/mamba-org/micromamba-releases/releases/download/${MICROMAMBA_VERSION}/micromamba-${osx_arch}"
    echo "Downloading micromamba ${MICROMAMBA_VERSION}"
    micromamba_exe="$(mktemp -d)/micromamba"
    curl -L -o "${micromamba_exe}" "${MICROMAMBA_URL}"
    chmod +x "${micromamba_exe}"
  fi
  echo "Creating environment"
  "${micromamba_exe}" create --yes --root-prefix ~/.conda --prefix "${MINIFORGE_HOME}" \
    --channel conda-forge \
    --file environment.yaml
fi

( endgroup "Provisioning build tools" ) 2> /dev/null

( startgroup "Configuring conda" ) 2> /dev/null

cat >~/.condarc <<CONDARC
always_yes: true
show_channel_urls: true
solver: libmamba
CONDARC

source "${MINIFORGE_HOME}/etc/profile.d/conda.sh"
conda activate base

echo -e "\n\nSetting up the condarc and mangling the compiler."
setup_conda_rc ./ ./recipes ./.ci_support/${CONFIG}.yaml
if [[ "${CI:-}" != "" ]]; then
  mangle_compiler ./ ./recipes .ci_support/${CONFIG}.yaml
fi

if [[ "${CI:-}" != "" ]]; then
  echo -e "\n\nMangling homebrew in the CI to avoid conflicts."
  /usr/bin/sudo mangle_homebrew
  /usr/bin/sudo -k
else
  echo -e "\n\nNot mangling homebrew as we are not running in CI"
fi

echo -e "\n\nRunning the build setup script."
source run_conda_forge_build_setup

set -e

# make sure there is a package directory so that artifact publishing works
mkdir -p "${CONDA_BLD_PATH}/osx-64/" "${CONDA_BLD_PATH}/osx-arm64/" "${CONDA_BLD_PATH}/noarch/"
# Make sure CONDA_BLD_PATH is a valid channel; only do it if noarch/repodata.json doesn't exist
# to save some time running locally
test -f "${CONDA_BLD_PATH}/noarch/repodata.json" || conda index "${CONDA_BLD_PATH}"

# Find the recipes from upstream:main in this PR and remove them.
echo ""
echo "Finding recipes merged in main and removing them from the build."
pushd ./recipes > /dev/null
if [ "${CI:-}" != "" ]; then
  git fetch --force origin main:main
fi
shopt -s extglob dotglob
git ls-tree --name-only main -- !(example|example-v1) | xargs -I {} sh -c "rm -rf {} && echo Removing recipe: {}"
shopt -u extglob dotglob
popd > /dev/null
echo ""

( endgroup "Configuring conda" ) 2> /dev/null

# Set the target arch or auto detect it
if [[ -z "${TARGET_ARCH}" ]]; then
  if [[ "$(uname -m)" == "arm64" ]]; then
    TARGET_ARCH="arm64"
  else
    TARGET_ARCH="64"
  fi
else
  echo "TARGET_ARCH is set to ${TARGET_ARCH}"
fi

# We just want to build all of the recipes.
echo "Building all recipes"
python .ci_support/build_all.py --arch ${TARGET_ARCH}

( startgroup "Inspecting artifacts" ) 2> /dev/null
# inspect_artifacts was only added in conda-forge-ci-setup 4.6.0; --all-packages in 4.9.3
command -v inspect_artifacts >/dev/null 2>&1 && inspect_artifacts --all-packages || echo "inspect_artifacts needs conda-forge-ci-setup >=4.9.3"
( endgroup "Inspecting artifacts" ) 2> /dev/null
