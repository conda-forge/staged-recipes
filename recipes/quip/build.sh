export QUIP_ARCH=linux_x86_64_gfortran
export MATH_LINKOPTS="-llapack -lblas"
export PYTHON="${PREFIX}/bin/python"
export PIP="${PREFIX}/bin/pip"
export EXTRA_LINKOPTS="none"

make config 
make -j ${NUM_CPUS}
make install-quippy
