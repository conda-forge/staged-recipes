#!/usr/bin/env bash

set -x

source .scripts/logging_utils.sh

( startgroup "Ensuring conda" ) 2> /dev/null

REPO_ROOT=$(dirname -- $(dirname -- "$(readlink -f -- "$BASH_SOURCE")"))
MINIFORGE_ROOT="${REPO_ROOT}/.pixi/envs/default"

if [[ ! command -v pixi >/dev/null 2>&1 ]]
  curl -fsSL https://pixi.sh/install.sh | bash
  export PATH="~/.pixi/bin:$PATH"
fi
echo "Creating environment"
pushd "$REPO_ROOT"
arch=$(uname -m)
if [[ "$arch" == "x86_64" ]]; then
  arch="64"
fi
sed -i.bak "s/platforms = .*/platforms = [\"osx-${arch}\"]/" pixi.toml
pixi install
pixi list
mv pixi.toml.bak pixi.toml
echo "Activating environment"
eval "$(pixi shell-hook)"
popd

( endgroup "Ensuring conda" ) 2> /dev/null

( startgroup "Configuring conda" ) 2> /dev/null

cat >~/.condarc <<CONDARC
always_yes: true
show_channel_urls: true
solver: libmamba
CONDARC

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
mkdir -p "${MINIFORGE_ROOT}/conda-bld/osx-64/" "${MINIFORGE_ROOT}/conda-bld/noarch/"

# Find the recipes from main in this PR and remove them.
echo ""
echo "Finding recipes merged in main and removing them from the build."
pushd ./recipes > /dev/null
git fetch --force origin main:main
git ls-tree --name-only main -- . | xargs -I {} sh -c "rm -rf {} && echo Removing recipe: {}"
popd > /dev/null
echo ""

( endgroup "Configuring conda" ) 2> /dev/null

# We just want to build all of the recipes.
echo "Building all recipes"
python .ci_support/build_all.py

( startgroup "Inspecting artifacts" ) 2> /dev/null
# inspect_artifacts was only added in conda-forge-ci-setup 4.6.0; --all-packages in 4.9.3
command -v inspect_artifacts >/dev/null 2>&1 && inspect_artifacts --all-packages || echo "inspect_artifacts needs conda-forge-ci-setup >=4.9.3"
( endgroup "Inspecting artifacts" ) 2> /dev/null
