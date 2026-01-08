set -euxo pipefail

mkdir -p build_sundials
cd build_sundials
KLU_INCLUDE_DIR=$PREFIX/include/suitesparse
KLU_LIBRARY_DIR=$PREFIX/lib

export CXXFLAGS="${CXXFLAGS} -I${KLU_INCLUDE_DIR}"
export CFLAGS="${CFLAGS} -I${KLU_INCLUDE_DIR}"

SUNDIALS_DIR=$SRC_DIR/sundials
cmake -DENABLE_LAPACK=ON\
      -DSUNDIALS_INDEX_SIZE=32\
      -DEXAMPLES_ENABLE:BOOL=OFF\
      -DENABLE_KLU=ON\
      -DENABLE_OPENMP=ON\
      -DKLU_INCLUDE_DIR=$KLU_INCLUDE_DIR\
      -DKLU_LIBRARY_DIR=$KLU_LIBRARY_DIR\
      -DCMAKE_INSTALL_PREFIX=$PREFIX\
      $SRC_DIR/sundials
make install -j10

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      export USE_PYTHON_CASADI=FALSE
      cd $SRC_DIR

      git clone -b build-linux-rooms-natively --single-branch https://github.com/agriyakhetarpal/casadi

      mkdir -p build_casadi
      cd build_casadi

        export LDFLAGS="-L${PREFIX}/lib/casadi -lcasadi"

      cmake -DWITH_PYTHON=OFF\
            -DWITH_PYTHON3=OFF\
            -DCMAKE_INSTALL_PREFIX=$PREFIX\
            $SRC_DIR/casadi
      make install -j10
fi

cd $SRC_DIR

python -m pip install -vv --no-deps --no-build-isolation .
