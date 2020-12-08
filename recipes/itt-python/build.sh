#!/usr/bin/env bash
set -ex

cd ${SRC_DIR}

${PYTHON} setup.py build_ext --incdir=${PREFIX}/include --ittlib=${PREFIX}/lib/libittnotify.a
${PYTHON} setup.py install
