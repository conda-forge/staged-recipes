# compile HOLE with gfortran
cd ${SRC_DIR}/src
source ../source.apache
export FC=${GFORTRAN}
make
make PREFIX=${PREFIX} install