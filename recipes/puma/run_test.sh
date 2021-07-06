#!/bin/bash
set -e  # exit when any command fails

# Test PuMA C++ library
PuMA_DIR="$SRC_DIR"

pumaX_testing 1

rm ${PREFIX}/bin/pumaX_main
rm ${PREFIX}/bin/pumaX_testing
rm ${PREFIX}/bin/pumaX_examples


# PuMA GUI
pumaGUI &
sleep 10
killall pumaGUI


# Test pumapy
cd "$SRC_DIR"/python/tests
$PYTHON -m unittest test_workspace.TestWorkspace
