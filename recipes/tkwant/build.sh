#!/bin/bash
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Darwin' ]]; then
   cp $RECIPE_DIR/build_mac.conf build.conf
else
   cp $RECIPE_DIR/build_linux.conf build.conf
fi

sed -i'' -e "s:PREFIX:$PREFIX:g" build.conf

export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

$PYTHON setup.py build
$PYTHON setup.py install
