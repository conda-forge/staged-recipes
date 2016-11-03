#!/bin/bash

pushd $SRC_DIR/tests

python -b -m pytest

popd
