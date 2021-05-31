#!/bin/bash

install_dirs=(
Services/monapi
SignalProcessing/dttalgo
)

pushd _build
set -ex

# install libclient.so
make -j ${CPU_COUNT} V=1 VERBOSE=1 -C Services install-exec-am lib_LTLIBRARIES="libclient.la"

# install others
for dir_ in ${install_dirs[@]}; do
    make -j ${CPU_COUNT} V=1 VERBOSE=1 install -C ${dir_}
done

