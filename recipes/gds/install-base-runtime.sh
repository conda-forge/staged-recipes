#!/bin/bash

install_dirs=(
RunFiles
)

pushd _build
set -ex
for dir_ in ${install_dirs[@]}; do
    make -j ${CPU_COUNT} V=1 VERBOSE=1 install -C ${dir_}
done

# install no_insert
make -j ${CPU_COUNT} V=1 VERBOSE=1 install-binSCRIPTS -C Services/TrigMgr
