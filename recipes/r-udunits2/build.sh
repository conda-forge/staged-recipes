#!/bin/bash

export UDUNITS2_INCLUDE=${PREFIX}/include
export UDUNITS2_LIB=${PREFIX}/lib

$R CMD INSTALL --build .
