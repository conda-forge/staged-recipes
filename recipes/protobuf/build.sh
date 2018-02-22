#!/bin/bash


if [ "$(uname)" == "Darwin" ];
then
    # Switch to clang with C++11 ASAP.
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
    export LIBS="-lc++"
fi

# Install python package now
cd python

# Begin fix for missing packages issue: https://github.com/conda-forge/protobuf-feedstock/issues/40
mkdir -p google/protobuf/util
mkdir -p google/protobuf/compiler
touch google/protobuf/util/__init__.py
touch google/protobuf/compiler/__init__.py
# End fix

python setup.py install --cpp_implementation --single-version-externally-managed --record record.txt
