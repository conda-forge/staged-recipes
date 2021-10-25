#!/usr/bin/env bash

if [[ $(uname) == Darwin ]]; then
    export LDFLAGS="-headerpad_max_install_names $LDFLAGS"
fi

# for qmake, since CXX includes $BUILD_PREFIX as a literal, which needs to be
# expanded for qmake to interpret it correctly:
export CXX="$(eval echo $CXX)"

CONDAFORGE=1 ./configure -verbose
./build -verbose
cp -r bin lib share "$PREFIX"

