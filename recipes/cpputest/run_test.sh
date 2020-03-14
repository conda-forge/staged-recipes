#! /bin/sh

mkdir -p test/build
cmake -S test -B test/build -G "Unix Makefiles" -DCMAKE_FIND_ROOT_PATH=$CONDA_PREFIX
cmake --build test/build --target all
cd test/build
ctest -V .

