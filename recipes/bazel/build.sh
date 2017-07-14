#!/bin/bash

set -v -x
sh compile.sh
mv output/bazel $PREFIX/bin
