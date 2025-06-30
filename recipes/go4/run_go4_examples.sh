#!/bin/bash
set -eumx -o pipefail
shopt -s failglob
shopt -s globstar
echo $GO4SYS
echo $PREFIX

pushd Go4ExampleSimple
make clean
make all -j$(nproc)
go4analysis -random -number 100000
popd

pushd Go4ExampleUserSource
make clean
make all -j$(nproc)
go4analysis -user tafoil50.scf
go4analysis -user befoil50.scf
popd
