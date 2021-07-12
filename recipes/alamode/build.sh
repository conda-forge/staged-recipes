#!/bin/bash
mkdir build; cd build
cmake -DUSE_MKL_FFT=no -DSPGLIB_ROOT=${PREFIX} ..
make -j${NUM_CPUS}
cp alm/* ${PREFIX}/bin
cp anphon/* ${PREFIX}/bin
cp tools/* ${PREFIX}/bin
