#!/bin/bash

# Add rpath to prebuilt binaries
${PYTHON} ${RECIPE_DIR}/fix_macos_rpath.py

# install
${PYTHON} -m pip install . --no-deps -vv
