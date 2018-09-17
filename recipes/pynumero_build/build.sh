#!/bin/bash -e

cd third_party/ASL
./getASL.sh
cd solvers
./configurehere

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    find . -name "makefile" -exec sed -i "s/CFLAGS = -DNo_dtoa -fPIC -O/CFLAGS = -fPIC -O/g" {} \;
elif [[ "$OSTYPE" == "darwin"* ]]; then
    find . -name "makefile" -exec sed -ie 's/CFLAGS = -DNo_dtoa -fPIC -O/CFLAGS = -fPIC -O/g' {} \;
fi
make
cd ../../../

mkdir build
cd build
echo "LOOKING FOR ampl-mp"
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    find /opt/conda/pkgs -type d -name "ampl-mp*"
    mp_dir=$(find /opt/conda/pkgs -type d -name "ampl-mp*")
elif [[ "$OSTYPE" == "darwin"* ]]; then
    find ~/ -type d -name "ampl-mp*"
    mp_dir=$(find ~/ -type d -name "ampl-mp*")
fi
echo $mp_dir
cmake .. -DMP_PATH=$mp_dir 

#make VERBOSE=1 -j${CPU_COUNT}
make 

cp asl_interface/libpynumero_* $PREFIX/lib
cp sparse_utils/libpynumero_* $PREFIX/lib
cp tests/asl_test $PREFIX/bin
