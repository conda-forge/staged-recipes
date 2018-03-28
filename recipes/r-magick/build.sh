#!/bin/bash

export CFLAGS="$(Magick++-config --cflags)"
export LDFLAGS="$(Magick++-config --libs)"

export LIB_DIR="$(Magick++-config --libs)"

$R CMD INSTALL --configure-vars="LIB_DIR={$LIB_DIR}" --build .
