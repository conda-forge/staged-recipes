#!/bin/bash

set -x

cp -r foam $PREFIX/

cd $PREFIX/foam

source OpenFOAM-v2106/etc/bashrc

echo "after bashrc" 

cd OpenFOAM-v2106/

# bin/tools/foamConfigurePaths \
#     -system-compiler Gcc \
#     -openmpi-system \
#     -boost boost-system \
#     -cgal  cgal-system \
#     -adios adios-system \
#     -adios2 adios2-system \
#     -metis metis-system \
#     -fftw  fftw-system \
#     -kahip kahip-none \
#     -scotch scotch-system \

# echo "CFLAGS += -I /opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/include -I /opt/conda/pkgs/flex-2.6.4-h58526e2_1004/include/" >> wmake/rules/linux64Gcc/c
# echo "c++FLAGS += -I /opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/include -I /opt/conda/pkgs/flex-2.6.4-h58526e2_1004/include/" >> wmake/rules/linux64Gcc/c++

# echo "CFLAGS += -I /opt/conda/pkgs/zlib-1.2.11-h7b6447c_3/include -I /opt/conda/pkgs/flex-2.6.4-h58526e2_1004/include/" >> wmake/rules/linux64Gcc/c

# echo "c++FLAGS += -I /opt/conda/pkgs/zlib-1.2.11-h7b6447c_3/include -I /opt/conda/pkgs/flex-2.6.4-h58526e2_1004/include/" >> wmake/rules/linux64Gcc/c++

# echo "c++FLAGS += -Wl,-rpath-link,/opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/lib" >> wmake/rules/linux64Gcc/c++
# echo "c++FLAGS += -Wl,-rpath-link,/opt/conda/lib" >> wmake/rules/linux64Gcc/c++

# echo "LIB_LIBS += -L /opt/conda/pkgs/zlib-1.2.11-h36c2ea0_1013/lib -lz" >> src/OpenFOAM/Make/options

./Allwmake -j

cd ..

source OpenFOAM-v2106/etc/bashrc

cd .. 

foamInstallationTest

foamTestTutorial -full incompressible/simpleFoam/pitzDaily


# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
