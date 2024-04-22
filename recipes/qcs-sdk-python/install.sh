#!/bin/bash

set -ex

# Install
${PYTHON} -m pip install dist/qcs_sdk_python-${PKG_VERSION}*.whl --no-deps --force-reinstall -vv
