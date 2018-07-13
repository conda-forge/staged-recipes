#!/usr/bin/env bash

# PLEASE NOTE: This script has been automatically generated by conda-smithy. Any changes here
# will be lost next time ``conda smithy rerender`` is run. If you would like to make permanent
# changes to this script, consider a proposal to conda-smithy so that other feedstocks can also
# benefit from the improvement.

set -xeuo pipefail
export PYTHONUNBUFFERED=1

cat >~/.condarc <<CONDARC

channels:
 - conda-forge
 - defaults

conda-build:
 root-dir: /home/conda/feedstock_root/build_artifacts

show_channel_urls: true

CONDARC

# A lock sometimes occurs with incomplete builds. The lock file is stored in build_artifacts.
conda clean --lock

conda install --yes --quiet conda-forge-ci-setup=1 conda-build
source run_conda_forge_build_setup

conda build /home/conda/recipe_root -m /home/conda/feedstock_root/.ci_support/${CONFIG}.yaml --quiet
upload_or_check_non_existence /home/conda/recipe_root conda-forge --channel=main -m /home/conda/feedstock_root/.ci_support/${CONFIG}.yaml

touch "/home/conda/feedstock_root/build_artifacts/conda-forge-build-done-${CONFIG}"