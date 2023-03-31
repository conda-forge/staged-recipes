#!/bin/bash

mkdir -p ${PREFIX}/lib/cmake
mkdir -p ${PREFIX}/include

mv thrust/thrust/cmake ${PREFIX}/lib/cmake/thrust
mv cub/cub/cmake ${PREFIX}/lib/cmake/cub
cp -r libcudacxx/lib/cmake/libcudacxx ${PREFIX}/lib/cmake

cp -r thrust/thrust ${PREFIX}/include
cp -r cub/cub ${PREFIX}/include
cp -r libcudacxx/include/cuda ${PREFIX}/include
cp -r libcudacxx/include/nv ${PREFIX}/include
