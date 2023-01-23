# compile HOLE with gfortran
cd ${SRC_DIR}/src
source ../source.apache

make FC=${GFORTRAN} CC=${GCC}
make FC=${GFORTRAN} CC=${GCC} PREFIX=${PREFIX} install