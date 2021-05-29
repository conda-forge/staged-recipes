cmake -DCMAKE_INSTALL_PREFIX=$PREFIX  -DCOSTA_SCALAPACK=CUSTOM  -DCOSTA_WITH_TESTS=ON

make -j${CPU_COUNT}

# workaround to run Open MPI in docker container
export OMPI_MCA_plm_rsh_agent=sh

# run tests
make test
#./tests/run_local_tests
#mpirun -n 2 ./tests/run_mpi_tests

# rebuild without tests to disable timers and make only API symbols visible
cmake -DCOSTA_WITH_TESTS=OFF
make -j${CPU_COUNT} install
