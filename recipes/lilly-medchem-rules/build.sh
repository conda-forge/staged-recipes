#!/bin/bash
set -ex

export CXXFLAGS="${CXXFLAGS} -std=c++11"

make

cp ./iwdemerit "${PREFIX}/bin/iwdemerit"
cp ./mc_first_pass "${PREFIX}/bin/mc_first_pass"
cp ./tsubstructure "${PREFIX}/bin/tsubstructure"
