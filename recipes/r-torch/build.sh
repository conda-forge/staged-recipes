#!/bin/bash
export DISABLE_AUTOBREW=1
export TORCH_INSTALL=1
${R} CMD INSTALL --build . ${R_ARGS}
