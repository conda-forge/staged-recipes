#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include

$R CMD INSTALL --build .
