#!/bin/bash

install_dirs=(
IO/framefast
IO/frameutils
)

pushd _build
set -ex

# install compiled executables only for each packages
# (libraries are in gds-base)
for dir_ in ${install_dirs[@]}; do
    make -j ${CPU_COUNT} V=1 VERBOSE=1 -C ${dir_} install-binPROGRAMS
done
