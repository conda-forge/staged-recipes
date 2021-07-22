#!/bin/bash

set -exuo pipefail

cp -r ${RECIPE_DIR}/tutorial .
cd tutorial

source gen-bazel-toolchain
bazel build --logging=6 --subcommands --verbose_failures --crosstool_top=//bazel_toolchain:toolchain --cpu ${TARGET_CPU} //main:hello-world 
