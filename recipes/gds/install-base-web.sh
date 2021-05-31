#!/bin/bash

install_dirs=(
Services/web
)

pushd _build
set -ex
# note we only install binPROGRAMS to not get header files we don't need
for dir_ in ${install_dirs[@]}; do
    make -j ${CPU_COUNT} V=1 VERBOSE=1 -C ${dir_} install-binPROGRAMS
done
