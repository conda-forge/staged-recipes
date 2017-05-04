
#!/bin/bash

mkdir build && cd build
cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DITK_DIR=$PREFIX/lib/cmake/ITK-4.11/ \
	..

make

make install
