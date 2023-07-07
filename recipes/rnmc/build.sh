#!/bin/bash

mkdir -p build

flags="-fno-rtti -fno-exceptions -std=c++17 -Wall -Wextra -g $(gsl-config --cflags) $(gsl-config --libs) -lsqlite3 -lpthread"

echo "building test_core"
echo "Running command" $CXX $flags ./core/test.cpp -o ./build/test_core
$CXX $flags ./core/test.cpp -o ./build/test_core
echo "building GMC"
echo "Running command" $CXX $flags ./GMC/GMC.cpp -o ./build/GMC
$CXX $flags ./GMC/GMC.cpp -o ./build/GMC
echo "building NPMC"
echo "Running command" $CXX $flags ./NPMC/NPMC.cpp -o ./build/NPMC
$CXX $flags ./NPMC/NPMC.cpp -o ./build/NPMC

cp ./build/GMC $PREFIX/bin/GMC
cp ./build/NPMC $PREFIX/bin/NPMC
