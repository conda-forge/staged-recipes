#!/bin/bash
set -ex

export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build . ${R_ARGS}
