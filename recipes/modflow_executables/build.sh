#!/bin/bash
set -ex

conda activate root

mkdir ~/build
cd ~/build

make-program mf2005,mfusg,triangle,gridgen --appdir "${PREFIX}/bin" --verbose

