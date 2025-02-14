#!/bin/bash
set -ex

conda activate root

pwd
BUILD_DIR="${SRC_DIR}/build"
mkdir $BUILD_DIR
cd $BUILD_DIR
pwd

PYMAKE_ARGS="mf2005,mfusg,triangle,gridgen --appdir ${PREFIX}/bin --verbose"
echo "${PYMAKE_ARGS}"

make-program ${PYMAKE_ARGS}

