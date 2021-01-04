#!/bin/bash
set -ex

# Run Siesta example
cd examples_to_run/SIESTA_chabazite_zeolite_example/DDEC6
ln -s ../chabazite.XSF chabazite.XSF
chargemol
cd -
