# compile HOLE with gfortran
cd ${SRC_DIR}/src
source ../source.apache
make
make PREFIX=${PREFIX} install