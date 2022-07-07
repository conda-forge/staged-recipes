#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

cd $SRC_DIR

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
if [ "$(uname)" == "Linux" ]; then
  export LDFLAGS="${LDFLAGS} -lrt"
fi

mkdir build
cd build

../configure \
  --without-hsl \
  --disable-java \
  --with-mumps \
  --with-mumps-cflags="-I${PREFIX}/include/mumps_seq" \
  --with-mumps-lflags="-ldmumps_seq -lmumps_common_seq -lpord_seq -lmpiseq_seq -lesmumps -lscotch -lscotcherr -lmetis -lgfortran" \
  --with-asl \
  --with-asl-cflags="-I${PREFIX}/include/asl" \
  --with-asl-lflags="-lasl" \
  --prefix=${PREFIX}

make -j${CPU_COUNT}
if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
  make test
fi
make install

# for backward compatibility
install -d ${PREFIX}/include/coin
install -m644 ${PREFIX}/include/coin-or/* ${PREFIX}/include/coin
