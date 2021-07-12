#!/bin/bash
mkdir build; cd build
cmake -DUSE_MKL_FFT=no -DSPGLIB_ROOT=${PREFIX} ..
make -j${NUM_CPUS}
cp alm/alm ${PREFIX}/bin
cp anphon/anphon ${PREFIX}/bin
cp tools/analyze_phonons ${PREFIX}/bin
cp tools/qe2alm ${PREFIX}/bin
cp tools/fc_virtual ${PREFIX}/bin
cp tools/dfc2 ${PREFIX}/bin
