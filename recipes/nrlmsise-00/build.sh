#!/bin/bash

# Setup
LIBNAME=libnrlmsise-00.so
if [ "$(uname)" == "Darwin" ]; then
    LIBNAME=libnrlmsise-00.dylib
    EXTRA_FLAGS="-dynamiclib -install_name @rpath/${LIBNAME}"
else
    EXTRA_FLAGS="-shared -Wl,-soname,${LIBNAME}"
fi

# Compile source code
cd "${SRC_DIR}" || exit
${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -I. -fPIC -c nrlmsise-00.c nrlmsise-00_data.c
${CC} ${EXTRA_FLAGS} -o ${LIBNAME} nrlmsise-00.o nrlmsise-00_data.o -lm

# Copy the library and header files to the Conda environment
mkdir -p "${PREFIX}"/lib
mkdir -p "${PREFIX}"/include/nrlmsise-00
cp ${LIBNAME} "${PREFIX}"/lib/
cp -- *.h "${PREFIX}/include/nrlmsise-00/"
