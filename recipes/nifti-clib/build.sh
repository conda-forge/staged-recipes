set -ex

sed -i.bak 's|$PWD/$DESTDIR/usr/local/bin|${PWD}/${DESTDIR}${PREFIX}/bin|' \
  nifti2/nifti_regress_test/cmake_testscripts/install_linking_test.sh

cmake -S . -B build \
  ${CMAKE_ARGS} \
  -DBUILD_SHARED_LIBS=ON \
  -DNIFTI_BUILD_APPLICATIONS=ON \
  -DUSE_NIFTICDF_CODE=ON \
  -DUSE_NIFTI2_CODE=ON \
  -DUSE_CIFTI_CODE=ON \
  -DUSE_FSL_CODE=OFF \
  -DNIFTI_BUILD_TESTING=ON \
  -DDOWNLOAD_TEST_DATA=ON

cmake --build build --parallel ${CPU_COUNT}
ctest --test-dir build -V --output-on-failure --parallel ${CPU_COUNT}
cmake --install build --parallel ${CPU_COUNT}
