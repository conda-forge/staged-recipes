#!/bin/bash
set -euo pipefail

PIP_NO_BUILD_ISOLATION=False \
    PIP_NO_DEPENDENCIES=True \
    PIP_IGNORE_INSTALLED=True \
    PIP_NO_INDEX=True \
    PYTHONDONTWRITEBYTECODE=True \
    #${PYTHON} -m pip install . --no-deps -vv
    ${PYTHON} -m pip install . --no-deps -vv --no-index