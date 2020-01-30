#!/usr/bin/env bash

export CPU_COUNT=2
export PYTHONUNBUFFERED=1

# Install Miniconda.
echo ""
echo "Installing a fresh version of Miniconda."
curl -L https://repo.continuum.io/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh > ~/miniconda.sh
bash ~/miniconda.sh -b -p ~/miniconda
touch ~/miniconda/conda-meta/pinned
echo "conda 4.6.14" >> ~/miniconda/conda-meta/pinned
(
    source ~/miniconda/bin/activate root

    # Configure conda.
    echo ""
    echo "Configuring conda."
    conda config --set show_channel_urls true
    conda config --set auto_update_conda false
    conda config --set add_pip_as_python_dependency false
    conda config --add channels conda-forge

    unset conda
    conda update -n root --yes --quiet conda
)
source ~/miniconda/bin/activate root

conda install --yes --quiet conda-forge-ci-setup=2.* conda-smithy=3.* conda-forge-pinning git=2.12.2 "conda-build>=3.16"

conda info
conda config --get

mkdir -p ~/.conda-smithy
echo $TRAVIS_TOKEN > ~/.conda-smithy/travis.token

python call_appveyor.py
