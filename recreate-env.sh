#!/bin/bash
# Commands to delete and recreate grass-build-test environment

# 1. Delete the existing environment
conda env remove -n grass-build-test

# 2. Recreate the environment with all necessary packages
conda create -n grass-build-test python=3.12 conda-build conda-forge-pinning -c conda-forge -y

# 3. Activate the environment
conda activate grass-build-test

# 4. (Optional) Install wxPython for GUI testing
conda install -c conda-forge wxpython -y

echo ""
echo "Environment 'grass-build-test' has been recreated!"
echo ""
echo "To use it:"
echo "  conda activate grass-build-test"
echo ""
echo "To build GRASS:"
echo "  cd /home/dudaka/opt/staged-recipes"
echo "  conda-build recipes/grass --output-folder ./build-output --no-anaconda-upload"
