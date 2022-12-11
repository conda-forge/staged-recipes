#!/usr/bin/env bash

set -x

echo -e "\n\nInstalling a fresh version of Mambaforge."
if [[ ${CI} == "travis" ]]; then
  echo -en 'travis_fold:start:install_mambaforge\\r'
fi
if [[ ! -z ${CONDA_EXE} ]]; then
    # Already installed, and activated
    CONDA_BASE_PREFIX=$(conda info --base)
elif [[ -d "${HOME}/Mambaforge" ]]; then
    # Already installed, but not activated
    CONDA_BASE_PREFIX="${HOME}/Mambaforge"
    source "${CONDA_BASE_PREFIX}/etc/profile.d/conda.sh"
else
    # Mambaforge not installed. Install it, then activate
    MAMBAFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download"
    MAMBAFORGE_FILE="Mambaforge-MacOSX-x86_64.sh"
    curl -L -O "${MAMBAFORGE_URL}/${MAMBAFORGE_FILE}"
    bash $MAMBAFORGE_FILE -b -p "${HOME}/Mambaforge"
    CONDA_BASE_PREFIX="${HOME}/Mambaforge"
    source "${CONDA_BASE_PREFIX}/etc/profile.d/conda.sh"
fi
if [[ ${CI} == "travis" ]]; then
  echo -en 'travis_fold:end:install_mambaforge\\r'
fi

echo -e "\n\nConfiguring conda."
if [[ ${CI} == "travis" ]]; then
  echo -en 'travis_fold:start:configure_conda\\r'
fi

conda activate base

echo -e "\n\nInstalling conda-forge-ci-setup=3, conda-build and boa."
mamba install -n base --yes --quiet "conda>4.7.12" conda-forge-ci-setup=3.* conda-forge-pinning networkx=2.4 "conda-build>=3.16" "boa"

echo -e "\n\nSetting up the condarc and mangling the compiler."
setup_conda_rc ./ ./recipes ./.ci_support/${CONFIG}.yaml
if [[ "${CI:-}" != "" ]]; then
  mangle_compiler ./ ./recipe .ci_support/${CONFIG}.yaml
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


if [[ ${CI} == "travis" ]]; then
  echo -en 'travis_fold:end:configure_conda\\r'
fi

set -e

# make sure there is a package directory so that artifact publishing works
mkdir -p "${CONDA_BASE_PREFIX}/conda-bld/osx-64/"

# Find the recipes from main in this PR and remove them.

echo ""
echo "Finding recipes merged in main and removing them from the build."
pushd ./recipes > /dev/null
git fetch --force origin main:main
git ls-tree --name-only main -- . | xargs -I {} sh -c "rm -rf {} && echo Removing recipe: {}"
popd > /dev/null
echo ""

# We just want to build all of the recipes.
python .ci_support/build_all.py
