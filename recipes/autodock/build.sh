#!/bin/bash

if [[ "$(uname)" = Linux ]]; then
    export CFLAGS="$CFLAGS -fopenmp"
    export CXXFLAGS="$CXXFLAGS -fopenmp"
    # MR: This step is done via yum_requirements.txt, so commenting it out here
    # yum install -q -y csh
    CONFIGURE='../configure'

else
    CONFIGURE='../configure-universalDarwin'
fi

mkdir -p autodock/build autogrid/build ${PREFIX}/bin
pushd ${SRC_DIR}/autodock/build
$CONFIGURE
make
cp autodock4 ${PREFIX}/bin
pushd ${SRC_DIR}/autogrid/build
$CONFIGURE
make
cp autogrid4 ${PREFIX}/bin

# MR: Copy a conveniece script from https://github.com/2019-ncovgroup/DataCrunching
cp -v ${RECIPE_DIR}/gen_tor_arg_list.sh ${PREFIX}/bin && \
    chmod +x ${PREFIX}/bin/gen_tor_arg_list.sh
