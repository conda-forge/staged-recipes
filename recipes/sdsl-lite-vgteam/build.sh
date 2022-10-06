#!/usr/bin/env bash

${SRC_DIR}/install.sh "${PREFIX}"

echo "Making a test build including all headers"
cd $SRC_DIR/build
make compile-test
