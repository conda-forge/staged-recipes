#!/bin/bash
cmake -B _build_intel -DCMAKE_BUILD_TYPE=Release .
make -C _build_intel DESTDIR=${PREFIX} install
