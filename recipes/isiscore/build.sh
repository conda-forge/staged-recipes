cd $SRC_DIR
mkdir build_core
cd build_core
export ISISROOT=$PREFIX

CORE_DIR=$(find . -type d -path "*/isis/src/core" | head -n 1)
echo "Using CORE_DIR=$CORE_DIR"

cmake -GNinja \
  ${CMAKE_ARGS} \
  -DBUILD_CORE_TESTS=OFF \
  -DISIS_BUILD_SWIG=ON \
  -DBUILD_COVERAGE=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_DATADIR=$PREFIX \
  "../$CORE_DIR"
ninja install
cd swig/python
${PYTHON} -m pip install . --no-deps --no-build-isolation --prefix=$PREFIX
