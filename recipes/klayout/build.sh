#!/bin/bash

# even though we specify QMAKE_CXX in -expert mode, qmake still
# needs "g++" while obtaining gcc paths (while bootstrapping?)
# So we create a temporary link called "g++"
mkdir tmp_exe
cd tmp_exe
ln -s $GXX g++
cd ..
export PATH=$(pwd)/tmp_exe:$PATH 

"${SRC_DIR}"/build.sh -python ${PYTHON} -bin "${PREFIX}/bin" -expert
echo "bin Contents"
echo "--------------------"
ls "${PREFIX}/bin"
