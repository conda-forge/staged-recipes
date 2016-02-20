#!/bin/bash
if [ `uname` == Darwin ]; then
    # Remove gfortran so that all fortran Py-ART modules are not built.  This
    # avoids the need to package the gfortran run time in the conda package.
    rm -f /usr/local/bin/gfor*
fi
export RSL_PATH=$PREFIX
$PYTHON setup.py install
