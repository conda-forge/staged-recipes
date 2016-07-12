#!/bin/bash

# scl enable devtoolset-2 bash

./compile.sh

cp output/bazel $PREFIX/bin/
