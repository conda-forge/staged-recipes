#!/bin/bash

set -euxo pipefail

# Download the right script to debug python processes.
# This is an useful script provided by CPython project to help debugging
# crashes in Python processes.
# See https://devguide.python.org/gdb for some
# examples on how to use it.
#
# Normally someone needs to download this script manually and properly
# setup gdb to load it (if you are lucky gdb was compiled with python
# support).
#
# Providing this in conda-forge's gdb makes the experience much smoother,
# avoiding all the hassles someone can find when trying to configure gdb
# for that.
curl -SL https://raw.githubusercontent.com/python/cpython/$PY_VER/Tools/gdb/libpython.py \
    > "$SP_DIR/libpython.py"

# Install a gdbinit file that will be automatically loaded
mkdir -p "$PREFIX/etc"
echo '
python
import gdb
import sys
import os
def setup_python(event):
    import libpython
gdb.events.new_objfile.connect(setup_python)
end
' >> "$PREFIX/etc/gdbinit"

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export CXXFLAGS="${CXXFLAGS} -std=gnu++17"
# TODO: remove once fixed
export CFLAGS="${CFLAGS} -Wno-error=incompatible-pointer-types"
export CFLAGS="${CFLAGS} -Wno-error=implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -Wno-error=incompatible-pointer-types"
export CXXFLAGS="${CXXFLAGS} -Wno-error=implicit-function-declaration"

# Setting /usr/lib/debug as debug dir makes it possible to debug the system's
# python on most Linux distributions

mkdir build-ze-server
pushd build-ze-server

$SRC_DIR/configure intelgt-linux-ze \
    --prefix="$PREFIX" \
    --target=$BUILD \
    --with-separate-debug-dir="$PREFIX/lib/debug:/usr/lib/debug" \
    --with-system-gdbinit="$PREFIX/etc/gdbinit" \
    --with-pkgversion="Intel(R) distribution for GDB*" \
    --disable-gdb \
    --disable-binutils \
    --disable-gas \
    --disable-gprof \
    --disable-inprocess-agent \
    --disable-intl \
    --with-curses \
    --with-libipt-prefix=${PREFIX} \
    --with-libiga64-prefix=${PREFIX} \
    --with-gmp=${PREFIX} \
    --with-mpfr=${PREFIX}  \
    --with-libze_loader-prefix="${PREFIX}/include/level_zero" \
    --with-intel-pt=yes \
    --with-yaml-cpp \
    --program-suffix="-ze"
make -j${CPU_COUNT} VERBOSE=1
make install

popd

mkdir build
pushd build

$SRC_DIR/configure \
    --prefix="$PREFIX" \
    --target=$BUILD \
    --with-separate-debug-dir="$PREFIX/lib/debug:/usr/lib/debug" \
    --with-python=${PYTHON} \
    --with-system-gdbinit="$PREFIX/etc/gdbinit" \
    --program-suffix="-oneapi" \
    --enable-targets=all \
    --disable-binutils \
    --disable-gas \
    --disable-gprof \
    --disable-inprocess-agent \
    --disable-intl \
    --with-curses \
    --with-libipt-prefix=${PREFIX} \
    --with-libiga64-prefix=${PREFIX} \
    --with-gmp=${PREFIX} \
    --with-mpfr=${PREFIX}  \
    --with-intel-pt=yes \
    --with-yaml-cpp \
    --with-pkgversion="Intel(R) distribution for GDB*" \
    ${libiconv_flag:-} \
    ${expat_flag:-} \
    || (cat config.log && exit 1)
make -j${CPU_COUNT} VERBOSE=1
make install

popd
