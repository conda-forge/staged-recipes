#!/usr/bin/env bash

# Update conda
conda update --yes -q conda #conda-build

# Answer yes to all questions (non-interactive)
conda config --set always_yes true

# We will upload explicitly at the end, if successful
conda config --set anaconda_upload no

# Create test environment
conda create --name test_env -c conda-forge python=2.7

# Make sure conda-forge is the first channel
#conda config --add channels conda-forge

# Activate test environment
source activate test_env
