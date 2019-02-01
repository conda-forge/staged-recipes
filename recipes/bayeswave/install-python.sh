#!/bin/bash

pushd ${SRC_DIR}/BayesWaveUtils
${PYTHON} -m pip install . --no-deps --ignore-installed -vv
