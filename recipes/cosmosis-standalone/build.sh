export LAPACK_LINK=-llapack -L${PREFIX}/lib

${PYTHON} -m pip install . -vv
