#!/bin/bash

# # download coinbrew
# curl -O https://raw.githubusercontent.com/coin-or/coinbrew/master/coinbrew
# chmod u+x coinbrew

# # coin-or osi and clp
# ./coinbrew build Osi --latest-release \
#     --skip-dependencies \
#     --prefix=$PREFIX \
#     --tests=none \
#     --without-cplex \
#     --without-gurobi \

# ./coinbrew build Clp --latest-release \
#     --skip-dependencies \
#     --prefix=$PREFIX \
#     --tests=none

git clone https://gitlab.com/stochastic-control/StOpt
cd StOpt
mkdir build
cd build
cmake -DBUILD_PYTHON=OFF -DBUILD_TEST=OFF ..
cmake --build . --config Release -j $(nproc)
cmake --install . --prefix "$PREFIX"
cd ..\..

# build SMS++
rmdir /S smspp-project
git clone -b develop --recurse-submodules https://gitlab.com/smspp/smspp-project.git

cd smspp-project
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --config Release -j $(nproc)
cmake --install . --prefix "$PREFIX"
