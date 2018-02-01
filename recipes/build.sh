#!/bin/bash

export F_MASTER=/summa-2.0.0
export FC_ENV=gfortran
export FC_EXE=gfortran

if [[ $(uname) == Darwin ]]; then
  export FC_ENV=gfortran-6-macports
elif [[ $(uname) == Linux ]]; then
  export FC_ENV=gfortran-6-docker

fi

make -C $F_MASTER/build/ -f Makefile

make clean
