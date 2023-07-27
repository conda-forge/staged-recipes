#!/bin/sh

set -ex

echo "The OpenMS library is linking the following dependencies with following licenses statically:" > thirdparty_licenses.txt

echo "eol-bspline:" >> thirdparty_licenses.txt
cat src/openms/thirdparty/eol-bspline/COPYRIGHT >> thirdparty_licenses.txt

echo "evergreen:" >> thirdparty_licenses.txt
cat src/openms/thirdparty/evergreen/license.txt >> thirdparty_licenses.txt

echo "Geometric Tools (Mathematics):" >> thirdparty_licenses.txt
cat src/openms/thirdparty/GTE/LICENSE >> thirdparty_licenses.txt

echo "IsoSpec:" >> thirdparty_licenses.txt
cat src/openms/thirdparty/IsoSpec/LICENSE >> thirdparty_licenses.txt

echo "Quadtree:" >> thirdparty_licenses.txt
cat src/openms/thirdparty/Quadtree/LICENSE >> thirdparty_licenses.txt

mkdir build
cd build

cmake .. \
  -DOPENMS_GIT_SHORT_REFSPEC="release/${PKG_VERSION}" \
  -DOPENMS_GIT_SHORT_SHA1="be787e9" \
  -DOPENMS_CONTRIB_LIBS="$SRC_DIR/contrib-build" \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DHAS_XSERVER=OFF \
  -DENABLE_TUTORIALS=OFF \
  -DENABLE_TOPP_TESTING=OFF \
  -DUSE_EXTERNAL_JSON=ON \
  -DUSE_EXTERNAL_SQLITECPP=ON \
  -DWITH_GUI=OFF \
  -DBOOST_USE_STATIC=OFF \
  -DBUILD_EXAMPLES=OFF \
  ${CMAKE_ARGS}

# limit concurrent build jobs due to memory usage on CI
make -j${CPU_COUNT} OpenMS TOPP UTILS
# The subpackages will do the installing of the parts
#make install
