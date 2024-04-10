#!/bin/bash

set -ex

# Install
${PYTHON} -m pip install qcs-sdk-python --find-links dist --force-reinstall
