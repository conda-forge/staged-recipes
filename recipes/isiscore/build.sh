mkdir build_core
cd build_core
export ISISROOT=$PREFIX

ISIS_CORE_DIR=$(find "$SRC_DIR" -type d -path "*/isis/src/core" | head -n 1)
echo "ISIS_CORE_DIR=$ISIS_CORE_DIR"

echo "=== DEBUG SOURCE TREE ==="
ls -R $SRC_DIR/isis-10.0.0_RC2/isis/src/core | head -100

echo "=== CHECK INCLUDE DIR ==="
ls $SRC_DIR/isis-10.0.0_RC2/isis/src/core/include || echo "NO INCLUDE DIR"

echo "=== FIND PVL ==="
find $SRC_DIR -name Pvl.h

cmake -GNinja \
  ${CMAKE_ARGS} \
  -DBUILD_CORE_TESTS=OFF \
  -DISIS_BUILD_SWIG=ON \
  -DBUILD_COVERAGE=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_DATADIR=$PREFIX \
  "$ISIS_CORE_DIR"
ninja install
cd swig/python
${PYTHON} -m pip install . --no-deps --no-build-isolation --prefix=$PREFIX
