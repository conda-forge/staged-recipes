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
echo "Folder content:"
cp make.inc make.inc.64
make
