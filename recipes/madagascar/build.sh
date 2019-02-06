#------------------------------------------------------------------------------
# Madagascar RSF package: build script for Unix OSes (Linux or macOS).

# Description of the `configure` arguments:
# API Comma-separated list of languages that need wrappers to the C libraries
# CC Path to the C compiler
# CPPPATH Additional paths for the C PreProcessor (CPP)
# LIBPATH Additional paths for looking for libraries
# SWIG The name of the `swig` executable (needed for Python API)
./configure \
    --prefix="$PREFIX" \
    API=python \
    CC="${CC}" \
    CPPPATH="${PREFIX}/include:${BUILD_PREFIX}/include" \
    LIBPATH="${PREFIX}/lib" \
    SWIG="${PREFIX}/bin/swig"

make -j "$CPU_COUNT"
make install

sed -i.bak '1 s|^.*$|#!/usr/bin/env python|g' "$PREFIX/bin/sfdoc"
