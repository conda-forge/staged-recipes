#!/bin/bash
set -ex

DENSITY_DIRECTORY=${PREFIX}/share/chargemol/atomic_densities/

# Run Siesta example
cd examples_to_run/SIESTA_chabazite_zeolite_example/DDEC6
ln -s ../chabazite.XSF chabazite.XSF

sed -i "s#/home/tamanz/bin/atomic_densities/#${DENSITY_DIRECTORY}#g" job_control.txt

chargemol
grep "Finished chargemol" chabazite.output
cd -
