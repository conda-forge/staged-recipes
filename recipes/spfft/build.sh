mkdir -p build
cd build
cmake .. ${CMAKE_ARGS} -DSPFFT_MPI=ON -DSPFFT_OMP=ON -DSPFFT_GPU_BACKEND=OFF -DSPFFT_GPU_DIRECT=OFF -DSPFFT_SINGLE_PRECISION=ON -DSPFFT_STATIC=OFF -DSPFFT_FORTRAN=ON -DSPFFT_BUILD_TESTS=ON
make -j${CPU_COUNT}

# workaround to run Open MPI in docker container
export OMPI_MCA_plm_rsh_agent=sh

# run tests
./tests/run_local_tests
mpirun -n 2 ./tests/run_mpi_tests

# rebuild without tests to disable timers and make only API symbols visible
cmake .. -DSPFFT_BUILD_TESTS=OFF
make -j${CPU_COUNT} install
