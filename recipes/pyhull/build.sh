#!/bin/bash 
patch < ${RECIPE_DIR}/pyhull.patch
python -m pip install . -vvv
