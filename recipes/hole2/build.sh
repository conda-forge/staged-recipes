# compile HOLE with gfortran
cd ${SRC_DIR}/src
source ../source.apache
export FC=${GFORTRAN}
make FC=${GFORTRAN}
make PREFIX=${PREFIX} install