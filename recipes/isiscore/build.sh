mkdir build_core
cd build_core
export ISISROOT=$PREFIX

cp $SRC_DIR/isis/src/core/IsisPreferences $ISISROOT
cp $SRC_DIR/isis/src/core/TestPreferences $ISISROOT

cmake -GNinja \
  -DBUILD_CORE_TESTS=ON \
  -DISIS_BUILD_SWIG=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_DATADIR=$PREFIX \
  -DPython3_EXECUTABLE=$PYTHON \
  -DPython3_ROOT_DIR=$PREFIX \
  $SRC_DIR/isis/src/core
ninja install
cd swig/python/
${PYTHON} ./setup.py install
