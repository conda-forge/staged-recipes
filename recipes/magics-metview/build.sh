#!/usr/bin/env bash

set -e

export PYTHON="$PYTHON"
export PYTHON_LDFLAGS="$PREFIX/lib"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

export REPLACE_TPL_ABSOLUTE_PATHS=0
if [[ $(uname) == Linux ]]; then
  export REPLACE_TPL_ABSOLUTE_PATHS=1
  # workaround for https://github.com/conda-forge/qt-feedstock/issues/123
  sed -i 's|_qt5gui_find_extra_libs(EGL.*)|_qt5gui_find_extra_libs(EGL "EGL" "" "")|g' $PREFIX/lib/cmake/Qt5Gui/Qt5GuiConfigExtras.cmake
  sed -i 's|_qt5gui_find_extra_libs(OPENGL.*)|_qt5gui_find_extra_libs(OPENGL "GL" "" "")|g' $PREFIX/lib/cmake/Qt5Gui/Qt5GuiConfigExtras.cmake
fi


mkdir ../build && cd ../build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DENABLE_FORTRAN=0 \
      -DENABLE_NETCDF=1 \
      -DENABLE_METVIEW=1 \
      -DREPLACE_TPL_ABSOLUTE_PATHS=$REPLACE_TPL_ABSOLUTE_PATHS \
      $SRC_DIR

make -j $CPU_COUNT

if [[ $(uname) == Linux ]]; then
    # Tell Linux where to find libGL.so.1 and other libs needed for Qt
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib64/
fi

ctest --output-on-failure -j $CPU_COUNT
make install

# Install activate/deactivate stripts
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/magics-activate.sh
cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/magics-deactivate.sh
