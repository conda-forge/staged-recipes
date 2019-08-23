#!/bin/bash

export F_MASTER=`pwd`
export FC=gfortran
export FC_EXE=gfortran
export FC_ENV=`uname`

make -C $F_MASTER/build/ -f Makefile
