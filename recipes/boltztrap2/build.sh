#!/bin/bash


if [ "$(uname)" == "Darwin" ]; then
    export CXX_FLAGS='-std=c++11 -stdlib=libc++'
    export CXXFLAGS="-std=c++11 -stdlib=libc++"
    export CMAKE_CXX_FLAGS='-stdlib=libc++'
    export LDFLAGS='-stdlib=libc++'
    export LD_FLAGS='-stdlib=libc++'
    export CMAKE_LDFLAGS='-stdlib=libc++'
fi

python -m pip install . --no-deps --ignore-installed -vv
