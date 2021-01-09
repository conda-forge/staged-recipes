#!/bin/bash
set -ex

DENSITIES_DIRECTORY=${PREFIX}/share/chargemol/atomic_densities/

# Run Siesta example
cd examples_to_run/SIESTA_chabazite_zeolite_example/DDEC6
ln -s $DENSITIES_DIRECTORY .
ln -s ../chabazite.XSF chabazite.XSF

sed -i "s#/home/tamanz/bin/atomic_densities/#atomic_densities/#g" job_control.txt

chargemol
ls -ltra
grep "Finished chargemol" chabazite.output
cd -
