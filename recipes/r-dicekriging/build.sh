#!/bin/sh

export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib
$R CMD INSTALL --build .
