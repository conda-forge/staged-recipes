#!/bin/bash

# For Sherpa v2, remove specific linker flags from LDFLAGS to ensure all libraries
# have symbols defined after the packaging step
if [[ "${build_platform}" == linux-* ]]; then
    # On Linux remove '--as-needed' flag
    # c.f. https://linux.die.net/man/1/ld
    export LDFLAGS="$(echo $LDFLAGS | sed 's/ -Wl,--as-needed//g')"
else
    # On macOS remove '-dead_strip_dylibs' flag
    # c.f. https://github.com/AnacondaRecipes/intel_repack-feedstock/issues/8
    export LDFLAGS="$(echo $LDFLAGS | sed 's/ -Wl,-dead_strip_dylibs//g')"
fi

autoreconf --install

./configure --help

# Sherpa v2 is Python 2 only, so disable Python
./configure \
    --prefix=$PREFIX \
    --enable-hepmc2=$PREFIX \
    --enable-lhapdf=$PREFIX \
    --with-sqlite3=$PREFIX \
    CXX="$CXX" \
    CXXFLAGS="$CXXFLAGS" \
    LDFLAGS="$LDFLAGS" \
    PYTHON=""

make --jobs="${CPU_COUNT}"
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    make check
fi
make install
