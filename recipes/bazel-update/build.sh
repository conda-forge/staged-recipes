#!/bin/bash

set -v -x

# useful for debugging:
export BAZEL_BUILD_OPTS='--linkopt "-fuse-ld=gold" --logging=6 --verbose_failures'
#export JAVA_HOME=$CONDA_PREFIX
./compile.sh
mv output/bazel $PREFIX/bin
