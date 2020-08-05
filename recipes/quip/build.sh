export QUIP_ARCH=linux_x86_64_gfortran
make config -llapack -lblas
make -j ${NUM_CPUS}
make install-quippy
