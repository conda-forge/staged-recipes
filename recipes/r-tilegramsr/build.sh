#!/bin/bash
export LD_LIBRARY_PATH=${PREFIX}/lib
$R CMD INSTALL --build .
