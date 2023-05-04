#!/bin/bash
set -e

echo "**************** M F R O N T  B U I L D  S T A R T S  H E R E ****************"

# https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#an-aside-on-cmake-and-sysroots

#export LDFLAGS="--sysroot ${CONDA_BUILD_SYSROOT} -L$PREFIX/lib -L${CONDA_BUILD_SYSROOT}/lib64 -lm -lpthread -L${CONDA_BUILD_SYSROOT}/usr/lib64 -lrt -ldl -L${PREFIX}/lib -lz -lgomp"
export LDFLAGS="-L$PREFIX/lib -lm -lpthread -lrt -ldl -lz -lgomp"
#export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -w"
export LIBPATH="$PREFIX/lib $LIBPATH"
cmake    -Wno-dev \
         -DCMAKE_BUILD_TYPE=Release \
         -Dlocal-castem-header=ON \
         -Denable-fortran=ON \
         -Denable-aster=ON \
         -Denable-cyrano=ON \
         -DPython_ADDITIONAL_VERSIONS=${CONDA_PY} \
         -DPYTHON_INCLUDE_DIRS=${PREFIX}/include \
         -DCOMPILER_CXXFLAGS="-I${PREFIX}/include -w" \
         -Denable-python=ON \
         -Denable-python-bindings=ON \
         -Denable-portable-build=ON \
         -DCMAKE_INSTALL_PREFIX=$PREFIX \
         -S . -B build

cmake --build ./build --config Release -j 1 # docker gets killed with higher parallelism
#make check -j # tentative fix for docker killed
cmake --install ./build --verbose

echo "**************** M F R O N T  B U I L D  E N D S  H E R E ****************"