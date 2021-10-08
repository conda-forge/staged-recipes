if [[ "$PKG_NAME" == "costa-scalapack" ]]; then
  COSTA_SCALAPACK=CUSTOM
else
  COSTA_SCALAPACK=OFF
fi

export CC=mpicc
export CXX=mpicxx


cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCOSTA_SCALAPACK=$COSTA_SCALAPACK \
    -DCOSTA_WITH_TESTS=ON \
    $CMAKE_ARG

make -j${CPU_COUNT}

# workaround to run Open MPI in docker container
export OMPI_MCA_plm_rsh_agent=sh

# run tests
make test

# rebuild without tests to disable timers and make only API symbols visible
cmake -DCOSTA_WITH_TESTS=OFF
make -j${CPU_COUNT} install
