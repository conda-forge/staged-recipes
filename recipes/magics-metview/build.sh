#!/usr/bin/env bash

set -e

export PYTHON="$PYTHON"
export PYTHON_LDFLAGS="$PREFIX/lib"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

export REPLACE_TPL_ABSOLUTE_PATHS=0
if [[ $(uname) == Linux ]]; then
  export REPLACE_TPL_ABSOLUTE_PATHS=1
fi

mkdir ../build && cd ../build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DENABLE_FORTRAN=0 \
      -DENABLE_NETCDF=1 \
      -DENABLE_METVIEW=1 \
      -DREPLACE_TPL_ABSOLUTE_PATHS=$REPLACE_TPL_ABSOLUTE_PATHS \
      $SRC_DIR

make -j $CPU_COUNT

ctest --output-on-failure -j $CPU_COUNT
make install

# Install activate/deactivate stripts
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/magics-activate.sh
cp $RECIPE_DIR/scripts/activate.fish $ACTIVATE_DIR/magics-activate.fish
cp $RECIPE_DIR/scripts/activate.csh $ACTIVATE_DIR/magics-activate.csh
cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/magics-deactivate.sh
cp $RECIPE_DIR/scripts/deactivate.fish $DEACTIVATE_DIR/magics-deactivate.fish
cp $RECIPE_DIR/scripts/deactivate.csh $DEACTIVATE_DIR/magics-deactivate.csh
