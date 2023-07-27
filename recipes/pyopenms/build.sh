#!/bin/sh

set -ex

mkdir build
cd build

cmake ../src/pyOpenMS \
  -DOPENMS_GIT_SHORT_REFSPEC="release/${PKG_VERSION}" \
  -DOPENMS_GIT_SHORT_SHA1="be787e9" \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DPython_EXECUTABLE=$PYTHON \
  -DPython_FIND_STRATEGY="LOCATION" \
  -DNO_DEPENDENCIES=ON \
  -DNO_SHARE=ON

# NO_DEPENDENCIES since conda takes over re-linking etc

# limit parallel jobs to 1 for memory usage since pyopenms has huge cython generated cpp files
make -j1 pyopenms
$PYTHON -m pip install ./pyOpenMS/dist/*.whl --ignore-installed --no-deps
