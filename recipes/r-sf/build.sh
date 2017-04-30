#!/bin/bash
export PROJ_LIB=${PREFIX}/share/proj
$R CMD INSTALL --build .
