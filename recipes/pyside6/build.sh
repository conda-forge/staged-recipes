#!/bin/sh

XVFB_RUN=""
if test `uname` = "Linux"
then
  XVFB_RUN="xvfb-run -s '-screen 0 640x480x24'"
  #ldd $PREFIX/lib/qt6/plugins/platforms/libqxcb.so
fi

pushd sources/shiboken6
mkdir build && cd build

cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
  -DBUILD_TESTS=OFF \
  -DPYTHON_EXECUTABLE=${PYTHON} \
  ..
cmake --build . --target install
popd

pushd sources/pyside6
mkdir build && cd build

cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -D_qt5Core_install_prefix=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTS=ON \
  -DPYTHON_EXECUTABLE=${PYTHON} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_MACOSX_RPATH=ON \
  ..
cmake --build . --target install

cp -v ./tests/pysidetest/libpysidetest${SHLIB_EXT} ${PREFIX}/lib
cp -v ./tests/pysidetest/testbinding.cpython-*.so ${SP_DIR}
eval ${XVFB_RUN} ctest -j${CPU_COUNT} --output-on-failure --timeout 30 -V || echo "no ok"
rm ${PREFIX}/lib/libpysidetest${SHLIB_EXT} ${SP_DIR}/testbinding.cpython-*.so
