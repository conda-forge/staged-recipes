#!/bin/bash

set -ex

export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

export CFLAGS="${CFLAGS} -D_GNU_SOURCE"
export CPPFLAGS="${CPPFLAGS} -D_GNU_SOURCE"

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  export CROSS_F77_SIZEOF_INTEGER=4
  export CROSS_F77_SIZEOF_REAL=4
  export CROSS_F77_SIZEOF_DOUBLE_PRECISION=8
  export CROSS_F77_TRUE_VALUE=1
  export CROSS_F77_FALSE_VALUE=0
  export CROSS_F90_ADDRESS_KIND=8
  export CROSS_F90_OFFSET_KIND=8
  export CROSS_F90_INTEGER_KIND=4
  export CROSS_F90_REAL_MODEL=" 6 , 37"
  export CROSS_F90_DOUBLE_MODEL=" 15 , 307"
fi

# Build shs-libfabric (non-CUDA version)
cd ${SRC_DIR}

autoreconf -ivf

./configure --prefix=${PREFIX} \
            --enable-cxi \
            --with-cassini-headers=${PREFIX} \
            --with-cxi-uapi-headers=${PREFIX} \
            --with-curl=${PREFIX} \
            --with-json-c=${PREFIX} \
            --with-libnl=${PREFIX} \
            --docdir=$PWD/noinst/doc \
            --mandir=$PWD/noinst/man \
            --disable-lpp \
            --disable-psm3 \
            --disable-opx \
            --disable-efa \
            --disable-static

make -j${CPU_COUNT} src/libfabric.la
make -j${CPU_COUNT} util/fi_info util/fi_pingpong util/fi_strerror util/fi_mon_sampler

make install-exec install-data
