#!/usr/bin/env bash

# Taken from Julia's source.
#
# ref: https://github.com/JuliaLang/julia/blob/v0.5.2/deps/unwind.mk#L5
#
CFLAGS="${CFLAGS} -U_FORTIFY_SOURCE -fPIC"

make prefix="${PREFIX}/"


# Install manually as there is no `make install`.
# Raised an issue upstream to address this.
#
# xref: https://github.com/JuliaLang/libosxunwind/issues/9

# Install the headers
mkdir -p "${PREFIX}/include"
cp -R "${SRC_DIR}/include/" "${PREFIX}/include/"

# Install the libraries
mkdir -p "${PREFIX}/lib"
cp "${SRC_DIR}/libosxunwind.a" "${PREFIX}/lib/"
cp "${SRC_DIR}/libosxunwind.dylib" "${PREFIX}/lib/"
