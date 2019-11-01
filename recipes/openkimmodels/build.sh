#!/bin/bash
tar Jxvf openkim-models-*.txz
cd openkim-models-*
cmake . -DCMAKE_Fortran_COMPILER=${FC} -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX} -DKIM_API_MODEL_DRIVER_INSTALL_PREFIX=${PREFIX}/lib64/openkim-models/model-drivers -DKIM_API_PORTABLE_MODEL_INSTALL_PREFIX=${PREFIX}/lib64/openkim-models/portable-models -DKIM_API_SIMULATOR_MODEL_INSTALL_PREFIX=${PREFIX}/lib64/openkim-models/simulator-models
make install
cp LICENSE ..
