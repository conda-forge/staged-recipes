#!/bin/sh

mkdir build
cd build

export BUILD_SP_DIR=$( $PYTHON -c "import pinocchio; print (pinocchio.__file__.split('/pinocchio/__init__.py')[0])")
export TARGET_SP_DIR=$SP_DIR

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  echo "Copying files from $BUILD_SP_DIR to $TARGET_SP_DIR"
  cp -r $BUILD_SP_DIR/pinocchio $TARGET_SP_DIR/pinocchio
  cp -r $BUILD_SP_DIR/numpy $TARGET_SP_DIR/numpy
fi

cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DPYTHON_EXECUTABLE=$PYTHON

make -j${CPU_COUNT} 
make install

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  echo $BUILD_PREFIX
  echo $PREFIX
  sed -i.back 's|'"$BUILD_PREFIX"'|'"$PREFIX"'|g' $PREFIX/lib/cmake/crocoddyl/crocoddylTargets.cmake
  rm $PREFIX/lib/cmake/crocoddyl/crocoddylTargets.cmake.back
fi
