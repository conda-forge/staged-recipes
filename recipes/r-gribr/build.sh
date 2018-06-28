#!/bin/bash

export ECCODES_LIBS=$PREFIX/lib
export ECCODES_CPPFLAGS=$PREFIX/include

$R CMD INSTALL --build .
