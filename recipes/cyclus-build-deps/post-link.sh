#!/bin/bash
set -e

if [ "$(uname)" == "Darwin" ]; then
  # other
  libext=".dylib"
else
  libext=".so"
fi

# Avoid accelerate
# If OpenBLAS is being used, we should be able to find the libraries.
# As OpenBLAS now will have all symbols that BLAS or LAPACK have,
# create libraries with the standard names that are linked back to
# OpenBLAS. This will make it easy for Cyclus to find it.
test -f "${PREFIX}/lib/libopenblas.a" && \
  ln -fs "${PREFIX}/lib/libopenblas.a" "${PREFIX}/lib/libblas.a"
test -f "${PREFIX}/lib/libopenblas.a" && \
  ln -fs "${PREFIX}/lib/libopenblas.a" "${PREFIX}/lib/liblapack.a"
test -f "${PREFIX}/lib/libopenblas${libext}" && \
  ln -fs "${PREFIX}/lib/libopenblas${libext}" "${PREFIX}/lib/libblas${libext}"
test -f "${PREFIX}/lib/libopenblas${libext}" && \
  ln -fs "${PREFIX}/lib/libopenblas${libext}" "${PREFIX}/lib/liblapack${libext}"
