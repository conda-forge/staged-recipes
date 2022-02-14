#!/bin/bash
DMD=ldmd2 ./build.d
mkdir -p ${PREFIX}/bin
mv bin/dub ${PREFIX}/bin
