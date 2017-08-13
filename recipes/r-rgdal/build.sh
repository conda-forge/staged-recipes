#!/bin/bash

export LD_LIBRARY_PATH=$PREFIX/lib/:${LD_LIBRARY_PATH}

$R CMD INSTALL --build .
