#!/bin/bash
set -e  # exit when any command fails

echo "Testing PuMA C++ library"
pumaX_testing 1
rm $CONDA_PREFIX/bin/pumaX_testing

echo "Testing PuMA GUI"
pumaGUI &
killall pumaGUI

echo "Testing pumapy"
cd python/tests
python -m unittest test_workspace.TestWorkspace
