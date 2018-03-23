echo "-------------------CUSTOM VARIABLES-------------"
export NETGENDIR=$PREFIX/lib/netgen
echo "set NETGENDIR to: $NETGENDIR"

export PYTHONPATH=$SP_DIR
echo "set PYTHONPATH to: $PYTHONPATH"
echo "------------------------------------------------"

mkdir build -p
cd build

cmake .. -G "Ninja" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DNG_INSTALL_DIR_INCLUDE=$PREFIX/include/netgen \
      -DNG_INSTALL_DIR_PYTHON=${SP_DIR} \
      -DOCC_INCLUDE_DIR=$PREFIX/include/opencascade \
      -DOCC_LIBRARY_DIR=$PREFIX/lib \
      -DUSE_NATIVE_ARCH=OFF \
      -DUSE_OCC=ON \
      -DUSE_PYTHON=ON \
      -DUSE_GUI=ON \
      -DUSE_SUPERBUILD=OFF \
      ..

ninja install

