#!/bin/bash
set -ex

test -f $PREFIX/bin/FreeFem++
test -f $PREFIX/bin/FreeFem++-nw
test -f $PREFIX/bin/ff-c++

FreeFem++ $PREFIX/share/FreeFEM/${PKG_VERSION}/examples/tutorial/beam.edp
