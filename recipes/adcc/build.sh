#!/bin/bash
set -eu

# First run h2o_sto3g tests
${PYTHON} setup.py test -a "-k h2o_sto3g"

# Now install adcc
${PYTHON} setup.py install --prefix=${PREFIX}
