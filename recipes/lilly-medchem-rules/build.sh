#!/bin/bash
set -ex

make

mkdir -p "${PREFIX}/bin/"

cp -p ./bin/mc_first_pass "${PREFIX}/bin/"
cp -p ./bin/tsubstructure "${PREFIX}/bin/"
cp -p ./bin/iwdemerit "${PREFIX}/bin/"
cp -p ./bin/mc_summarise "${PREFIX}/bin/"
