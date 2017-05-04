
#!/bin/bash

mkdir build && cd build
cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
	..

make

make install
