mkdir -p build
cd build
cmake .. ${CMAKE_ARGS} -DSPLA_OMP=OFF -DSPLA_GPU_BACKEND=OFF -DSPLA_STATIC=OFF -DSPLA_FORTRAN=ON
make -j${CPU_COUNT} install
