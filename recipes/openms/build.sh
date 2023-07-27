#!/bin/sh

set -ex

echo "The OpenMS library is linking the following dependencies with the following licenses statically:" > thirdparty_licenses.txt

echo "eol-bspline:" >> thirdparty_licenses.txt
cat src/openms/thirdparty/eol-bspline/COPYRIGHT >> thirdparty_licenses.txt

echo "evergreen:" >> thirdparty_licenses.txt
cat src/openms/thirdparty/evergreen/license.txt >> thirdparty_licenses.txt

echo "Geometric Tools (Mathematics):" >> thirdparty_licenses.txt
cat src/openms/thirdparty/GTE/LICENSE >> thirdparty_licenses.txt

echo "IsoSpec:" >> thirdparty_licenses.txt

cat << EOF >> thirdparty_licenses.txt
IsoSpec is provided under the terms of 2-clause BSD licence.
If you require other licensing terms, please contact the authors.

We would appreciate if you let us know if you use this library in
your own software, but you are under no legal obligation to do so.


-------------------------------------------------------------------------


Copyright (c) 2015-2020, Michal Startek and Mateusz Lacki

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

EOF

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
