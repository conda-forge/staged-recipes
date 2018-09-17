#!/bin/bash -e

cd third_party/ASL
./getASL.sh
cd solvers
./configurehere
make
cd ../../../

mkdir build
cd build

mp_dir=$(find ~/ -type d -name "ampl-mp*")
echo $mp_dir
cmake .. -DMP_PATH=$mp_dir 

make VERBOSE=1 -j${CPU_COUNT}
make 
