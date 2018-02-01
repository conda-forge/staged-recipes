#!/bin/bash

set -x -e

export F_MASTER=`pwd`
export FC=gfortran
export FC_EXE=gfortran


if [[ $(uname) == Darwin ]]; then
  export FC_ENV=gfortran-6-macports
elif [[ $(uname) == Linux ]]; then
  export FC_ENV=gfortran-6-docker

fi

make -C $F_MASTER/build/ -f Makefile
