#!/bin/bash

mkdir -p $PREFIX/bin
cd src/
cd libbsc/
make CC=$CXX
cd ../
$CXX nlms_helper.cpp -std=c++11 -Wall -O3 $CFLAGS -o nlms_helper.out $LDFLAGS
cp nlms_helper.out $PREFIX/bin
mkdir -p $PREFIX/bin/libbsc
cp nlms_helper.out $PREFIX/bin/
cp libbsc/bsc $PREFIX/bin/libbsc
(echo "#!/usr/bin/env python3" && cat nlms_compress.py) > nlms_compress_1.py
cp nlms_compress_1.py $PREFIX/bin/lfzip-nlms
chmod +x $PREFIX/bin/lfzip-nlms
