#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="-O2 -march=native -fomit-frame-pointer -I${PREFIX}/include ${CFLAGS}"
export CXXFLAGS="-O2 -march=native -fomit-frame-pointer -I${PREFIX}/include ${CXXFLAGS}"

if [[ ${target_platform} =~ .*osx.* ]]; then
    sed -i 's?SUBDIRS = C ASM/x86?SUBDIRS = C?' lzma/Makefile.am
    sed -i 's/-f elf64/-f macho64/' configure.ac
fi
autoreconf --force --install --verbose
configure_args=""
if [[ ${target_platform} == "osx-arm64" ]]; then
    configure_args="--disable-asm"
fi
./configure --prefix=$PREFIX ${configure_args}
make -j${CPU_COUNT} V=1 SHELL=bash
make install
