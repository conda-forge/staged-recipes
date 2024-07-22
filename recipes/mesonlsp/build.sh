#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Fix problem with libarchive pkgconfig
sed -i '/Requires.private/d' ${PREFIX}/lib/pkgconfig/libarchive.pc

# Backport fixes for macOS. Remove with next release
sed -i "s/'-Wl,-ld_classic'//" meson.build
sed -i 's/and !defined(__x86_64__)//g' src/polyfill/polyfill.hpp

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
if [[ ${target_platform} =~ .*linux.* ]]; then
    export CFLAGS="${CFLAGS} -pthread"
    export CXXFLAGS="${CXXFLAGS} -pthread"
fi

meson ${MESON_ARGS} build
meson compile -C build -v
meson install -C build
