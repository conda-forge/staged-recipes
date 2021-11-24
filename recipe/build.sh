#!/bin/bash

set -x

cp -r foam $PREFIX/

ln -s $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-gcc $CONDA_PREFIX/bin/gcc
ln -s $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-g++ $CONDA_PREFIX/bin/g++
ln -s $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-c++ $CONDA_PREFIX/bin/c++
ln -s $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-gfortran $CONDA_PREFIX/bin/gfortran
ln -s $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-ld $CONDA_PREFIX/bin/ld
ln -s $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-as $CONDA_PREFIX/bin/as
ln -s $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-nm $CONDA_PREFIX/bin/nm
ln -s $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-cpp $CONDA_PREFIX/bin/cpp
ln -s $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-ld.bfd $CONDA_PREFIX/bin/ld.bfd
ln -s $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-ld.gold $CONDA_PREFIX/bin/ld.gold
ln -s $CONDA_PREFIX/bin/x86_64-conda-linux-gnu-ar $CONDA_PREFIX/bin/ar

cd $PREFIX/foam

source OpenFOAM-v2106/etc/bashrc

echo "after bashrc" 

cd OpenFOAM-v2106/

bin/tools/foamConfigurePaths \
    -system-compiler Gcc \
    -openmpi-system \
    -boost boost-system \
    -cgal  cgal-system \
    -adios adios-system \
    -adios2 adios2-system \
    -metis metis-system \
    -fftw  fftw-system \
    -kahip kahip-none \
    -scotch scotch-system \


echo "CFLAGS += -I /opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/include -I /opt/conda/pkgs/flex-2.6.4-h58526e2_1004/include/" >> wmake/rules/linux64Gcc/c
echo "c++FLAGS += -I /opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/include -I /opt/conda/pkgs/flex-2.6.4-h58526e2_1004/include/" >> wmake/rules/linux64Gcc/c++

echo "CFLAGS += -I /opt/conda/pkgs/zlib-1.2.11-h7b6447c_3/include -I /opt/conda/pkgs/flex-2.6.4-h58526e2_1004/include/" >> wmake/rules/linux64Gcc/c

echo "c++FLAGS += -I /opt/conda/pkgs/zlib-1.2.11-h7b6447c_3/include -I /opt/conda/pkgs/flex-2.6.4-h58526e2_1004/include/" >> wmake/rules/linux64Gcc/c++

echo "c++FLAGS += -Wl,-rpath-link,/opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/lib" >> wmake/rules/linux64Gcc/c++
echo "c++FLAGS += -Wl,-rpath-link,/opt/conda/lib" >> wmake/rules/linux64Gcc/c++

echo "LIB_LIBS += -L /opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/lib -lz" >> src/OpenFOAM/Make/options

./Allwmake -j

cd ..

source OpenFOAM-v2106/etc/bashrc

cd .. 

foamInstallationTest

foamTestTutorial -full incompressible/simpleFoam/pitzDaily
