#!/bin/bash
cat << EOF > conda_forge_config
[main]
fc = mpifort 
ld = mpifort
f90_module_flag = -J 
[opt]
fflags = ${FFLAGS}

[dbg]
fflags = ${FFLAGS}
EOF
./tools/mkconfig conda_forge_config
make
