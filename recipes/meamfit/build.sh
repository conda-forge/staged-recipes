#!/bin/bash
cat << EOF > conda_forge_config
[main]
fc = mpifort 
ld = mpifort
f90_module_flag = -J 
[opt]
fflags = ${FFLAGS} -ffree-line-length-0

[dbg]
fflags = ${FFLAGS} -ffree-line-length-0
EOF
./tools/mkconfig conda_forge_config
cp make.inc make.inc.64

make
mkdir -p ${PREFIX}/bin
cp bin/MEAMfit.x ${PREFIX}/bin
