#!/bin/bash

export DISABLE_AUTOBREW=1

grep -va '^Priority: ' DESCRIPTION.old > DESCRIPTION
# shellcheck disable=SC2086
${R} CMD INSTALL --build . ${R_ARGS}
