#!/bin/bash
export PYCVODES_LAPACK=openblas
export PYCVODES_SUNDIALS_LIBS=sundials_cvodes,sundials_nvecserial,sundials_sunlinsollapackdense,sundials_sunlinsollapackband
cat <<EOF>pycvodes/_config.py
env = {
    'LAPACK': "${PYCVODES_LAPACK}",
    'SUNDIALS_LIBS': "${PYCVODES_SUNDIALS_LIBS}"
}
EOF
export PYCVODES_STRICT=1
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
${PYTHON} -m pip install --no-deps --ignore-installed .
