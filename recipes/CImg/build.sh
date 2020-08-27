#!/bin/bash

mkdir ${PREFIX}/include/
cp ${SRC_DIR}/CImg.h ${PREFIX}/include/
mkdir -p ${PREFIX}/include/CImg
cp -a ${SRC_DIR}/plugins ${PREFIX}/include/CImg
