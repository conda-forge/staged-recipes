#!/bin/bash

set -ex

# Install
${PYTHON} -m pip install qcs-sdk-python --find-links dist --force-reinstall

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
