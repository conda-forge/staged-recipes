#!/bin/bash -e

cd third_party/ASL
./getASL.sh
cd solvers
./configurehere
find . -name "makefile" -exec sed -i "s/CFLAGS = -DNo_dtoa -fPIC -O/CFLAGS = -fPIC -O/g" {} \;
make
cd ../../../

mkdir build
cd build
echo "LOOKING FOR ampl-mp"
find /opt/conda/pkgs -type d -name "ampl-mp*"
mp_dir=$(find /opt/conda/pkgs -type d -name "ampl-mp*")
echo $mp_dir
cmake .. -DMP_PATH=$mp_dir 

make VERBOSE=1 -j${CPU_COUNT}
make 
