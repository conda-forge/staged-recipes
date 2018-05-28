#!/bin/bash
export PYCVODES_LAPACK=openblas

# Sundials 2.7:
export PYCVODES_SUNDIALS_LIBS=sundials_cvodes,sundials_nvecserial

# Sundials 3.1:
#export PYCVODES_SUNDIALS_LIBS=sundials_cvodes,sundials_nvecserial,sundials_sunlinsollapackdense,sundials_sunlinsollapackband

cat <<EOF>pycvodes/_config.py
env = {
    'LAPACK': "${PYCVODES_LAPACK}",
    'SUNDIALS_LIBS': "${PYCVODES_SUNDIALS_LIBS}"
}
EOF
export PYCVODES_STRICT=1
python -m pip install --no-deps --ignore-installed .
