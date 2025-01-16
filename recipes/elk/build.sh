#!/usr/bin/env bash

set -xe

cp -f ${RECIPE_DIR}/make.inc .

make all

install -m 0755 src/elk ${PREFIX}/bin/
install -m 0755 src/eos/eos ${PREFIX}/bin/
install -m 0755 src/spacegroup/spacegroup ${PREFIX}/bin/
