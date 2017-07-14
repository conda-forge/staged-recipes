#!/bin/bash

# scl enable devtoolset-2 bash

export JAVA_HOME=/usr/java/default/

./compile.sh

cp output/bazel $PREFIX/bin/
