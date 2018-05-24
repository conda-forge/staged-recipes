#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    export CXX="${CXX} -stdlib=libc++"
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib"

    # remove -lrt
    sed -i '.bak' 's/ -lrt//g' $SRC_DIR/wrappers/numpy/Makefile
fi

# Python3 fixes
if [[ "${PY_VER}" =~ 3 ]]
then
  find $SRC_DIR/utils -name "*.py" -exec 2to3 -w -n {} \;
fi

# numpy bindings
cd wrappers/numpy
make python
python setup.py install
