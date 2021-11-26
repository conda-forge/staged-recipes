#!/bin/bash
export DISABLE_AUTOBREW=1

# shellcheck disable=SC2086
${R} CMD INSTALL --build changeforest-r ${R_ARGS}