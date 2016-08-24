#!/usr/bin/env bash
set -e

if [ "$(uname)" == "Darwin" ]; then
  # toolchain copy
  export CC=clang
  export CXX=clang++
  export MACOSX_VERSION_MIN="10.9"
  export MACOSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}"
  export CMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}"
  export CFLAGS="${CFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
  export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
  export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export LDFLAGS="${LDFLAGS} -lc++"
  export LINKFLAGS="${LDFLAGS}"
  export CFLAGS="${CFLAGS} -m${ARCH}"
  export CXXFLAGS="${CXXFLAGS} -m${ARCH}"
  # other
  libext=".dylib"
  export LDFLAGS="-rpath ${PREFIX}/lib ${LDFLAGS}"
  export LINKFLAGS="${LDFLAGS}"
  skiprpath="-DCMAKE_SKIP_RPATH=TRUE"
else
  libext=".so"
  skiprpath=""
fi

# Avoid accelerate
# If OpenBLAS is being used, we should be able to find the libraries.
# As OpenBLAS now will have all symbols that BLAS or LAPACK have,
# create libraries with the standard names that are linked back to
# OpenBLAS. This will make it easy for NumPy to find it.
test -f "${PREFIX}/lib/libopenblas.a" && \
  ln -fs "${PREFIX}/lib/libopenblas.a" "${PREFIX}/lib/libblas.a"
test -f "${PREFIX}/lib/libopenblas.a" && \
  ln -fs "${PREFIX}/lib/libopenblas.a" "${PREFIX}/lib/liblapack.a"
test -f "${PREFIX}/lib/libopenblas.${libext}" && \
  ln -fs "${PREFIX}/lib/libopenblas.${libext}" "${PREFIX}/lib/libblas.${libext}"
test -f "${PREFIX}/lib/libopenblas.${libext}" && \
  ln -fs "${PREFIX}/lib/libopenblas.${libext}" "${PREFIX}/lib/liblapack.${libext}"

# Install Cyclus
export VERBOSE=1
${PYTHON} install.py --prefix="${PREFIX}" \
  --build_type="Release" \
  --dont-allow-milps \
  --deps-root="${PREFIX}" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}" \
  -DBLAS_LIBRARIES="-L${PREFIX}/lib -lopenblas" \
  -DLAPACK_LIBRARIES="-L${PREFIX}/lib -llapack" \
  ${skiprpath} \
  --clean -j "${CPU_COUNT}"

# Clean up accelerate avoidance
# Need to clean these up as we don't want them as part of the NumPy package.
# If these are part of a BLAS (e.g. ATLAS), this won't cause us any problems
# as those would have been existing packages and `conda-build` would have
# ignored packaging those files anyways.
rm -f "${PREFIX}/lib/libblas.a"
rm -f "${PREFIX}/lib/liblapack.a"
rm -f "${PREFIX}/lib/libblas.${libext}"
rm -f "${PREFIX}/lib/liblapack.${libext}"
