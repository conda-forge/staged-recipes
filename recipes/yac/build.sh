#!/bin/bash

set -x

autoreconf -vfi

export CC=mpicc
export FC=mpifort

if [[ "${mpi}" == "openmpi" ]]; then
  export MPI_LAUNCH="${PREFIX}/bin/mpirun --oversubscribe"
  export OMPI_MCA_plm_rsh_agent=""
else
  export MPI_LAUNCH="${PREFIX}/bin/mpirun"
fi

./configure --prefix=${PREFIX} \
            --with-yaxt-root=${PREFIX} \
            --disable-netcdf \
            --disable-examples \
            --disable-tools \
            --disable-deprecated \
            --enable-python-bindings \
            --with-pic

make -j ${CPU_COUNT} all

make install

export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${PREFIX}/lib/pkgconfig
${CC} -shared ./src/core/*.o $(pkg-config yac-core --variable clibs) -I${PREFIX}/include -target ${target_platform} -o libyac_core.so
${CC} -shared ./src/mci/*.o $(pkg-config yac-mci --variable clibs) -I${PREFIX}/include -target ${target_platform}  -o libyac_mci.so
${CC} -shared ./src/utils/*.o $(pkg-config yac-utils --variable clibs) -I${PREFIX}/include -target ${target_platform}  -o libyac_utils.so

cp libyac_core.so ${PREFIX}/lib/
cp libyac_mci.so ${PREFIX}/lib/
cp libyac_utils.so ${PREFIX}/lib/
