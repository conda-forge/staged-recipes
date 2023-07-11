#!/usr/bin/env bash
set -e -x

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=ON \
    ..

make -k -j${CPU_COUNT}

cd mysql-test/
./mysql-test-run.pl --suite=main --ps-protocol --parallel=auto --skip-test=session_tracker_last_gtid

cd ../unittest/libmariadb
ctest -V

cd ..
make install