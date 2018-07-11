#!/bin/bash

export CFLAGS="$(Magick++-config --cflags)"
export LDFLAGS="$(Magick++-config --libs)"

$R CMD INSTALL --build .
