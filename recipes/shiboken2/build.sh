#!/bin/sh

# Remove running without PYTHONPATH
sed -i.bak "s/, '-E'//g" sources/shiboken2/libshiboken/embed/embedding_generator.py
sed -i.bak 's/${PYTHON_EXECUTABLE} -E/${PYTHON_EXECUTABLE}/g' sources/shiboken2/libshiboken/CMakeLists.txt

pushd sources/shiboken2
mkdir -p build && cd build

# https://www.qt.io/blog/qt-on-apple-silicon

cmake ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTS=OFF \
  -DPYTHON_EXECUTABLE=${PYTHON} \
  ..
make install -j${CPU_COUNT} VERBOSE=1
popd

${PYTHON} setup.py dist_info --build-type=shiboken2
cp -r shiboken2-${PKG_VERSION}.dist-info "${SP_DIR}"/
