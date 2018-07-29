#!/bin/bash
set -ex

export _composer_xe_dir="compilers_and_libraries_2016.3.210"

if [ "$ARCH" = "32" ]; then
    _i_arch='ia32'
else
    _i_arch='intel64'
fi

source ${PREFIX}/opt/intel/${_composer_xe_dir}/linux/mkl/bin/mklvars.sh ${_i_arch}
