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
echo "Folder content:"
ls
cp make.inc make.inc.64
make
