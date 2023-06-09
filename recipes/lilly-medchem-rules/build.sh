#!/bin/bash
set -ex

make

mkdir -p "${PREFIX}/bin/"

cp ../mc_first_pass "${PREFIX}/bin/"
cp ../tsubstructure "${PREFIX}/bin/"
cp ../iwdemerit "${PREFIX}/bin/"
cp ../mc_summarise "${PREFIX}/bin/"
