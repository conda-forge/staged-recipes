#!/bin/bash
python -m pip install . -vv --install-option="--mfem-prefix=${PREFIX}" --install-option="--mfem-source=${PREFIX}/include/mfem"
