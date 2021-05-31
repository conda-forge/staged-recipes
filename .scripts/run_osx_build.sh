#!/usr/bin/env bash

source .scripts/logging_utils.sh

set -xe

MINIFORGE_HOME=${MINIFORGE_HOME:-${HOME}/miniforge3}

( startgroup "Installing a fresh version of Miniforge" ) 2> /dev/null

MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download"
MINIFORGE_FILE="Miniforge3-MacOSX-x86_64.sh"
curl -L -O "${MINIFORGE_URL}/${MINIFORGE_FILE}"
bash $MINIFORGE_FILE -b -p ${MINIFORGE_HOME}

( endgroup "Installing a fresh version of Miniforge" ) 2> /dev/null

( startgroup "Configuring conda" ) 2> /dev/null

BUILD_CMD=build

source ${MINIFORGE_HOME}/etc/profile.d/conda.sh
conda activate base

echo -e "\n\nInstalling conda-forge-ci-setup=3 and conda-build."
conda install -n base --quiet --yes "conda-forge-ci-setup=3" conda-build pip ${GET_BOA:-}



echo -e "\n\nSetting up the condarc and mangling the compiler."
setup_conda_rc ./ ./recipe ./.ci_support/${CONFIG}.yaml

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



( endgroup "Configuring conda" ) 2> /dev/null


echo -e "\n\nMaking the build clobber file"
make_build_number ./ ./recipe ./.ci_support/${CONFIG}.yaml

if [[ "${HOST_PLATFORM}" != "${BUILD_PLATFORM}" ]]; then
    EXTRA_CB_OPTIONS="${EXTRA_CB_OPTIONS:-} --no-test"
fi

conda $BUILD_CMD ./recipe -m ./.ci_support/${CONFIG}.yaml --suppress-variables --clobber-file ./.ci_support/clobber_${CONFIG}.yaml ${EXTRA_CB_OPTIONS:-}
( startgroup "Validating outputs" ) 2> /dev/null

validate_recipe_outputs "${FEEDSTOCK_NAME}"

( endgroup "Validating outputs" ) 2> /dev/null

( startgroup "Uploading packages" ) 2> /dev/null

if [[ "${UPLOAD_PACKAGES}" != "False" ]]; then
  upload_package --validate --feedstock-name="${FEEDSTOCK_NAME}" ./ ./recipe ./.ci_support/${CONFIG}.yaml
fi

( endgroup "Uploading packages" ) 2> /dev/null