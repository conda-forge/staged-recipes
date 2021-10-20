#!/bin/bash
set -e
set -x
env QT_SELECT=qt5

cd ${SRC_DIR}

#We are dependent on an ancient idas version 1.3.0 ...
sh compile_libraries.sh idas

# QMAKE depends on g++, which is not allowd by conda, but I am not going to fix
# that, so we workaround instead
mkdir -p bin
ln -sf $CXX bin/g++
export PATH=`pwd`/bin:$PATH

sh compile.sh cool_prop
sh compile.sh units
sh compile.sh config
sh compile.sh core

sh compile.sh idas 
sh compile.sh data_reporting

sh compile.sh activity
sh compile.sh superlu

cd daetools-package
$PYTHON -m pip install . 
