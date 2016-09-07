set -e

export PETSC_DIR=${PREFIX}
cd ${SRC_DIR}/src/snes/examples/tests
make ex1
make runex1
