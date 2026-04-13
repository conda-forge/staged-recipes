mkdir build_core
cd build_core
export ISISROOT=$PREFIX

ISIS_CORE_DIR=$(find "$SRC_DIR" -type d -path "*/isis/src/core" | head -n 1)
cp "$ISIS_CORE_DIR/IsisPreferences" "$ISISROOT"
cp "$ISIS_CORE_DIR/TestPreferences" "$ISISROOT"

cmake -GNinja \
  ${CMAKE_ARGS} \
  -DBUILD_CORE_TESTS=OFF \
  -DISIS_BUILD_SWIG=ON \
  -DBUILD_COVERAGE=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_DATADIR=$PREFIX \
  $SRC_DIR/isis/src/core
ninja install
cd swig/python
${PYTHON} -m pip install . --no-deps --no-build-isolation --prefix=$PREFIX
