# compile HOLE with gfortran
cd ${SRC_DIR}/src
source ../source.apache

FFLAGS+=" -fd-lines-as-comments "

make FC=${GFORTRAN} CC=${CC_FOR_BUILD} CFLAGS="${CFLAGS}" FFLAGS="${FFLAGS}"
make FC=${GFORTRAN} CC=${CC_FOR_BUILD} PREFIX=${PREFIX} install-all CFLAGS="${CFLAGS}" FFLAGS="${FFLAGS}"
