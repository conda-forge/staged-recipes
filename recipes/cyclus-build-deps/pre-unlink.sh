#!/bin/bash
set -e

if [ "$(uname)" == "Darwin" ]; then
  # other
  libext=".dylib"
else
  libext=".so"
fi

# Need to clean these up.
rm -f "${PREFIX}/lib/libblas.a"
rm -f "${PREFIX}/lib/liblapack.a"
rm -f "${PREFIX}/lib/libblas${libext}"
rm -f "${PREFIX}/lib/liblapack${libext}"
