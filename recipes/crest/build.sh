#!/bin/bash
cmake -B build_dir -DCMAKE_BUILD_TYPE=Release .
make -C build_dir
cp crest ${PREFIX}/bin
