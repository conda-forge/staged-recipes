#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
export CC=gcc

$R CMD INSTALL --build .
