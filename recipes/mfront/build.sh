#!/bin/bash
set -e

echo "**************** M F R O N T  B U I L D  S T A R T S  H E R E ****************"

# https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#an-aside-on-cmake-and-sysroots

#export LDFLAGS="--sysroot ${CONDA_BUILD_SYSROOT} -L$PREFIX/lib -L${CONDA_BUILD_SYSROOT}/lib64 -lm -lpthread -L${CONDA_BUILD_SYSROOT}/usr/lib64 -lrt -ldl -L${PREFIX}/lib -lz -lgomp"
export LDFLAGS="-L$PREFIX/lib -lm -lpthread -lrt -ldl -lz -lgomp"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
export LIBPATH="$PREFIX/lib $LIBPATH"
mkdir build -p
cd build
#echo "boost include dir : "
#ls $PREFIX/include/boost 
cmake .. -DCMAKE_BUILD_TYPE=Release -Dlocal-castem-header=ON -Denable-fortran=ON -Denable-aster=ON -Denable-cyrano=ON -DPython_ADDITIONAL_VERSIONS=${CONDA_PY} -Denable-python=ON -Denable-python-bindings=OFF -Denable-broken-boost-python-module-visibility-handling=ON -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j 1 # docker gets killed with higher parallelism
#make check -j # tentative fix for docker killed
make install

echo "**************** M F R O N T  B U I L D  E N D S  H E R E ****************"