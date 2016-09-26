#!/usr/bin/env bash
set -e

if [ "$(uname)" == "Darwin" ]; then
  #libext=".dylib"
  #export LDFLAGS="-rpath ${PREFIX}/lib ${LDFLAGS}"
  #export LINKFLAGS="${LDFLAGS}"
  skiprpath="-DCMAKE_SKIP_RPATH=TRUE"
else
  #libext=".so"
  skiprpath=""
fi

# Avoid accelerate
# If OpenBLAS is being used, we should be able to find the libraries.
# As OpenBLAS now will have all symbols that BLAS or LAPACK have,
# create libraries with the standard names that are linked back to
# OpenBLAS. This will make it easy for NumPy to find it.
#test -f "${PREFIX}/lib/libopenblas.a" && \
#  ln -fs "${PREFIX}/lib/libopenblas.a" "${PREFIX}/lib/libblas.a"
#test -f "${PREFIX}/lib/libopenblas.a" && \
#  ln -fs "${PREFIX}/lib/libopenblas.a" "${PREFIX}/lib/liblapack.a"
#test -f "${PREFIX}/lib/libopenblas${libext}" && \
#  ln -fs "${PREFIX}/lib/libopenblas${libext}" "${PREFIX}/lib/libblas${libext}"
#test -f "${PREFIX}/lib/libopenblas${libext}" && \
#  ln -fs "${PREFIX}/lib/libopenblas${libext}" "${PREFIX}/lib/liblapack${libext}"

# Install PyNE
export VERBOSE=1
${PYTHON} setup.py install \
  --build-type="Release" \
  --prefix="${PREFIX}" \
  --hdf5="${PREFIX}" \
  --moab="${PREFIX}" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}" \
  ${skiprpath} \
  --clean -j "${CPU_COUNT}"

# Create data library
scripts/nuc_data_make

#  -DBLAS_LIBRARIES="-L${PREFIX}/lib -lopenblas" \
#  -DLAPACK_LIBRARIES="-L${PREFIX}/lib -llapack" \

# Clean up accelerate avoidance
# Need to clean these up as we don't want them as part of the NumPy package.
# If these are part of a BLAS (e.g. ATLAS), this won't cause us any problems
# as those would have been existing packages and `conda-build` would have
# ignored packaging those files anyways.
#rm -f "${PREFIX}/lib/libblas.a"
#rm -f "${PREFIX}/lib/liblapack.a"
#rm -f "${PREFIX}/lib/libblas${libext}"
#rm -f "${PREFIX}/lib/liblapack${libext}"
