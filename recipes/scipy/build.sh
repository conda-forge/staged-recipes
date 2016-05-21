#!/bin/bash


# Letting SciPy set these for us.
# This may not be the best long term strategy,
# but it works fine to get our first build.
unset LDFLAGS

# Depending on our platform, shared libraries end with either .so or .dylib
if [[ `uname` == 'Darwin' ]]; then
    DYLIB_EXT=dylib
else
    DYLIB_EXT=so
fi

# If OpenBLAS is being used, we should be able to find the libraries.
# As OpenBLAS now will have all symbols that BLAS or LAPACK have,
# create libraries with the standard names that are linked back to
# OpenBLAS. This will make it easy for NumPy to find it.
test -f "${PREFIX}/lib/libopenblas.a" && ln -fs "${PREFIX}/lib/libopenblas.a" "${PREFIX}/lib/libblas.a"
test -f "${PREFIX}/lib/libopenblas.a" && ln -fs "${PREFIX}/lib/libopenblas.a" "${PREFIX}/lib/liblapack.a"
test -f "${PREFIX}/lib/libopenblas.${DYLIB_EXT}" && ln -fs "${PREFIX}/lib/libopenblas.${DYLIB_EXT}" "${PREFIX}/lib/libblas.${DYLIB_EXT}"
test -f "${PREFIX}/lib/libopenblas.${DYLIB_EXT}" && ln -fs "${PREFIX}/lib/libopenblas.${DYLIB_EXT}" "${PREFIX}/lib/liblapack.${DYLIB_EXT}"

$PYTHON setup.py install

# Need to clean these up as we don't want them as part of the NumPy package.
# If these are part of a BLAS (e.g. ATLAS), this won't cause us any problems
# as those would have been existing packages and `conda-build` would have
# ignored packaging those files anyways.
rm -f "${PREFIX}/lib/libblas.a"
rm -f "${PREFIX}/lib/liblapack.a"
rm -f "${PREFIX}/lib/libblas.${DYLIB_EXT}"
rm -f "${PREFIX}/lib/liblapack.${DYLIB_EXT}"
