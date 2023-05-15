#!/bin/bash
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build ./client-api_r/generated ${R_ARGS}