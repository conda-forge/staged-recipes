#!/usr/bin/env bash

make install
# add the binaries to a separate package gpiod-tools as they are GPL
rm $PREFIX/bin/gpio*
