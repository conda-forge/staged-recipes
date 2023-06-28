#!/bin/sh

# Otherwise libraries won't be found during linking on Linux
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib

# Otherwise Error: dyld: Symbol not found: _iconv Referenced from: /usr/lib/libarchive.2.dylib
# Expected in: /Users/runner/mambaforge/conda-bld/openms-meta_1686666744655/_h_env_placehold_/lib/libiconv.2.dylib
#export DYLD_LIBRARY_PATH=${PREFIX}/lib

mkdir build
cd build

cmake .. \
  -DOPENMS_GIT_SHORT_REFSPEC="release/${PKG_VERSION}" \
  -DOPENMS_GIT_SHORT_SHA1="d36094e" \
  -DOPENMS_CONTRIB_LIBS="$SRC_DIR/contrib-build" \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
  -DCMAKE_MACOSX_RPATH=ON \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_RPATH=${RPATH} \
  -DCMAKE_INSTALL_NAME_DIR="@rpath" \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -DCMAKE_BUILD_WITH_INSTALL_NAME_DIR=ON \
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
