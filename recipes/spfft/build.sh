mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="${PREFIX}"  -DSPFFT_MPI=ON -DSPFFT_OMP=ON -DSPFFT_GPU_BACKEND=OFF -DSPFFT_GPU_DIRECT=OFF -DSPFFT_SINGLE_PRECISION=ON -DSPFFT_STATIC=OFF -DSPFFT_FORTRAN=ON -DSPFFT_BUILD_TESTS=ON
make -j2

# run tests
./tests/run_local_tests
mpirun -n 2 ./tests/run_mpi_tests

# rebuild without tests to disable timers and make only API symbols visible
cmake .. -DSPFFT_BUILD_TESTS=OFF
make -j2 install
