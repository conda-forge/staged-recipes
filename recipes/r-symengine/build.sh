#!/bin/bash
set -o errexit -o pipefail
export DISABLE_AUTOBREW=1
export SymEngine_DIR=$PREFIX
${R} CMD INSTALL --build .
