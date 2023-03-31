#!/bin/bash

mkdir -p ${PREFIX}/lib/cmake
mkdir -p ${PREFIX}/include

mv -v thrust/thrust/cmake ${PREFIX}/lib/cmake/thrust
mv -v cub/cub/cmake ${PREFIX}/lib/cmake/cub
cp -rv libcudacxx/lib/cmake/libcudacxx ${PREFIX}/lib/cmake

cp -rv thrust/thrust ${PREFIX}/include
cp -rv cub/cub ${PREFIX}/include
cp -rv libcudacxx/include/cuda ${PREFIX}/include
cp -rv libcudacxx/include/nv ${PREFIX}/include
