#!/bin/bash

mkdir -p $PREFIX/bin
cd src/
$CXX nlms_helper.cpp -std=c++11 -Wall -O3 $CFLAGS -o nlms_helper.out $LDFLAGS
cp nlms_helper.out $PREFIX/bin
(echo "#!/usr/bin/env python3" && cat nlms_compress.py) > nlms_compress_1.py
# fix bsc path from dependency
sed "s/BSC_PATH = .*/BSC_PATH = 'bsc'/g" nlms_compress_1.py > $PREFIX/bin/lfzip-nlms 
chmod +x $PREFIX/bin/lfzip-nlms
