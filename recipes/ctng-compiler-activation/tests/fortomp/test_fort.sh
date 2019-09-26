cmake \
    -H${SRC_DIR} \
    -Bbuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_Fortran_COMPILER=${GFORTRAN} \
    -DCMAKE_Fortran_FLAGS="${FFLAGS}" \
    .
