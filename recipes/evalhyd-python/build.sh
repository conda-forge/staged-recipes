#!/bin/bash

# fix problem for macOS build
# https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# prevent vendoring of dependencies
export EVALHYD_PYTHON_VENDOR_XTL="FALSE"
export EVALHYD_PYTHON_VENDOR_XTENSOR="FALSE"
export EVALHYD_PYTHON_VENDOR_XTENSOR_PYTHON="FALSE"
export EVALHYD_PYTHON_VENDOR_EVALHYD_CPP="FALSE"

${PYTHON} -m pip install . -vvv
