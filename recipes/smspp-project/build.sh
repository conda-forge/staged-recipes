#!/bin/bash

# download coinbrew
curl -O https://raw.githubusercontent.com/coin-or/coinbrew/master/coinbrew
chmod u+x coinbrew

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
cmake --build . -j $(nproc)
cmake --install . --prefix "$PREFIX"
cd ../..

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$/opt/coin-or/lib"

# build SMS++
rm -fr smspp-project
git clone -b develop --recurse-submodules https://gitlab.com/smspp/smspp-project.git

cd smspp-project
mkdir build
cd build
cmake ..
cmake --build . --config Release -j $(nproc)
cmake --install . --prefix "$PREFIX"

