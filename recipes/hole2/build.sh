# compile HOLE with gfortran
cd ${SRC_DIR}/src
source ../source.apache
make FC=${GFORTRAN}
make PREFIX=${PREFIX} install