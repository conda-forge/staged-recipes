#!/bin/bash

export CFLAGS="$(Magick++-config --cflags)"
export LDFLAGS="$(Magick++-config --libs)"

export DISABLE_AUTOBREW=1
$R CMD INSTALL --build .
