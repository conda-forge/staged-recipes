#!/bin/bash

  mkdir build
  autoconf
  cd build
  ../configure --prefix=$PREFIX
  make -j$CPU_COUNT
  make install
