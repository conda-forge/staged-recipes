mkdir build_core
cd build_core
export ISISROOT=$PREFIX

cp $SRC_DIR/isis/src/core/IsisPreferences $ISISROOT
cp $SRC_DIR/isis/src/core/TestPreferences $ISISROOT

cmake -GNinja \
  -DBUILD_CORE_TESTS=OFF \
  -DISIS_BUILD_SWIG=ON \
  -DBUILD_COVERAGE=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_DATADIR=$PREFIX \
  -DPYTHON_EXECUTABLE=$PYTHON \
  -DPYTHON_INCLUDE_DIR=$PREFIX/include/python${PY_VER} \
  -DPYTHON_LIBRARY=$PREFIX/lib/libpython${PY_VER}.so \
  $SRC_DIR/isis/src/core
ninja install
cd swig/python/
chmod +x setup.py
${PYTHON} ./setup.py install
