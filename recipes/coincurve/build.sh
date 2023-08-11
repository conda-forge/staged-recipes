#!/bin/bash
set -euo pipefail

cp $BUILD_PREFIX/share/gnuconfig/config.* .
${PYTHON} setup.py install

