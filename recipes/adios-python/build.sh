#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
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
$PYTHON setup.py install
