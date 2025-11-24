#!/bin/bash
set -eumx -o pipefail
shopt -s failglob

pushd Go4ExampleSimple
make clean
make -j"$(nproc)"
go4analysis -random -number 100000
popd

pushd Go4ExampleUserSource
make clean
make all -j"$(nproc)"
go4analysis -user tafoil50.scf
go4analysis -user befoil50.scf
popd
