#!/bin/bash
set -o errexit -o pipefail
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build .
