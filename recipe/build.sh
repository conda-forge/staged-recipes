#!/bin/bash

set -x

ls $CONDA_PREFIX/bin/
ls $CONDA_PREFIX/
ls /opt/conda/pkgs/
ls /opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/

mv foam $HOME/

cd $CONDA_PREFIX/bin/
ln -s x86_64-conda-linux-gnu-gcc gcc
ln -s x86_64-conda-linux-gnu-g++ g++
ln -s x86_64-conda-linux-gnu-c++ c++
ln -s x86_64-conda-linux-gnu-gfortran gfortran
ln -s x86_64-conda-linux-gnu-ld ld
ln -s x86_64-conda-linux-gnu-as as
ln -s x86_64-conda-linux-gnu-nm nm
ln -s x86_64-conda-linux-gnu-cpp cpp
ln -s x86_64-conda-linux-gnu-ld.bfd ld.bfd
ln -s x86_64-conda-linux-gnu-ld.gold ld.gold
ln -s x86_64-conda-linux-gnu-ar ar

cd $HOME/foam

echo "before bashrc"

source OpenFOAM-v2106/etc/bashrc

echo "after bashrc" 

cd ThirdParty-v2106/

echo "CFLAGS  += -I /opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/include" >> etc/makeFiles/scotch/Makefile.inc.OpenFOAM-Linux.shlib
echo "LDFLAGS += -L /opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/lib" >> etc/makeFiles/scotch/Makefile.inc.OpenFOAM-Linux.shlib

./Allwmake

ls /opt/conda/pkgs/

cd ../OpenFOAM-v2106/

echo "CFLAGS += -I /opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/include -I /opt/conda/pkgs/flex-2.6.4-ha10e3a4_1/include/" >> wmake/rules/linux64Gcc/c
echo "c++FLAGS += -I /opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/include -I /opt/conda/pkgs/flex-2.6.4-ha10e3a4_1/include/" >> wmake/rules/linux64Gcc/c++

echo "CFLAGS += -I /opt/conda/pkgs/zlib-1.2.11-h7b6447c_3/include -I /opt/conda/pkgs/flex-2.6.4-ha10e3a4_1/include/" >> wmake/rules/linux64Gcc/c

echo "c++FLAGS += -I /opt/conda/pkgs/zlib-1.2.11-h7b6447c_3/include -I /opt/conda/pkgs/flex-2.6.4-ha10e3a4_1/include/" >> wmake/rules/linux64Gcc/c++

echo "c++FLAGS += -Wl,-rpath-link,$HOME/foam/ThirdParty-v2106/platforms/linux64Gcc/gperftools-svn/lib" >> wmake/rules/linux64Gcc/c++
echo "c++FLAGS += -Wl,-rpath-link,$HOME/foam/OpenFOAM-v2106/platforms/linux64GccDPInt32Opt/lib/openmpi-system" >> wmake/rules/linux64Gcc/c++
echo "c++FLAGS += -Wl,-rpath-link,$HOME/foam/ThirdParty-v2106/platforms/linux64GccDPInt32/lib/openmpi-system" >> wmake/rules/linux64Gcc/c++
# echo "c++FLAGS += -Wl,-rpath-link,$HOME/foam/site/v2106/platforms/linux64GccDPInt32Opt/lib" >> wmake/rules/linux64Gcc/c++
echo "c++FLAGS += -Wl,-rpath-link,$HOME/foam/OpenFOAM-v2106/platforms/linux64GccDPInt32Opt/lib" >> wmake/rules/linux64Gcc/c++
echo "c++FLAGS += -Wl,-rpath-link,$HOME/foam/ThirdParty-v2106/platforms/linux64GccDPInt32/lib" >> wmake/rules/linux64Gcc/c++
echo "c++FLAGS += -Wl,-rpath-link,$HOME/foam/OpenFOAM-v2106/platforms/linux64GccDPInt32Opt/lib/dummy" >> wmake/rules/linux64Gcc/c++
echo "c++FLAGS += -Wl,-rpath-link,/opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/lib" >> wmake/rules/linux64Gcc/c++
echo "c++FLAGS += -Wl,-rpath-link,/opt/conda/lib" >> wmake/rules/linux64Gcc/c++


echo "LIB_LIBS += -L /opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/lib -lz" >> src/OpenFOAM/Make/options

./Allwmake -j

