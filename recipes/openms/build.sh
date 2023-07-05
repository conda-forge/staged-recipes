#!/bin/sh

set -ex

mkdir build
cd build

cmake .. \
  -DOPENMS_GIT_SHORT_REFSPEC="release/${PKG_VERSION}" \
  -DOPENMS_GIT_SHORT_SHA1="d36094e" \
  -DOPENMS_CONTRIB_LIBS="$SRC_DIR/contrib-build" \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DHAS_XSERVER=OFF \
  -DENABLE_TUTORIALS=OFF \
  -DWITH_GUI=OFF \
  -DBOOST_USE_STATIC=OFF \
  -DBoost_NO_BOOST_CMAKE=ON \
  -DBoost_ARCHITECTURE="-x64" \
  -DBUILD_EXAMPLES=OFF \
  ${CMAKE_ARGS}

# limit concurrent build jobs due to memory usage on CI
make -j${CPU_COUNT} OpenMS TOPP UTILS
# The subpackages will do the installing of the parts
#make install
