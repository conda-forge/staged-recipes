#!/usr/bin/env bash

set -x
set -e

SOURCE_CODE_DIR=${SRC_DIR:-$(dirname $0)/..}

TESTS="${SOURCE_CODE_DIR}/examples/TestTraits.py ${SOURCE_CODE_DIR}/examples/TestNEAT_xor.py ${SOURCE_CODE_DIR}/examples/TestHyperNEAT_xor.py"

echo $TESTS | xargs -n 1 -P 4 python

