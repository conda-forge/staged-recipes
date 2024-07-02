#!/bin/sh

# For macOS, we provide this additionnal script as an hotfix
# for users who would like to load SofaPython3 plugin in runSofa 
# application. 
# The bug seems to be linked to the fact that python in conda-forge package
# is linked statically with libpython, and thus embeds symbols in the executable.
# On macOS, if a binary which links dynamically with libpython is loaded with
# such python executable, this leads to a segfault. SofaPython3 embeds both 
# python bindings and a python interpreter so far, so it needs python symbols.
# This should be fixed in the future where SofaPython3 will split bindings and interpreter
# part. Meanwhile, we chose to remove the dynamic link to libpython on macOS from
# SofaPython3 to make it usable in python with conda (and will use symbols from
# static linkage of python). If a user wants to load SofaPython3 in runSofa (so outside python),
# it has to preload libpython symbols. This scripts is just an helper to so that.
# Initial issue: https://github.com/sofa-framework/SofaPython3/issues/393
# PR: https://github.com/sofa-framework/SofaPython3/pull/394

if ! python --version; then
    echo "No python installation found"
    exit 1
fi

PYTHON_VERSION_MAJOR_MINOR=`python -c 'import sys; version=sys.version_info[:2]; print("{0}.{1}".format(*version))'`
echo $PYTHON_VERSION_MAJOR_MINOR

PYTHON_LIB=$CONDA_PREFIX/lib/libpython$PYTHON_VERSION_MAJOR_MINOR.dylib
if [[ ! -f "$PYTHON_LIB" ]]; then
    echo "Could not find python library $PYTHON_LIB"
    exit 1
fi

DYLD_INSERT_LIBRARIES=$PYTHON_LIB ./runSofa