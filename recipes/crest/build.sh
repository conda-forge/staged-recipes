#!/bin/bash
cmake -B build_dir -DCMAKE_BUILD_TYPE=Release
make -C build_dir
mkdir -p ${PREFIX}/bin
cp build_dir/crest ${PREFIX}/bin
