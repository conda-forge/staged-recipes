#!/bin/bash

mkdir -p ${PREFIX}/bin

cd chargemol_09_26_2017
cd chargemol_FORTRAN_09_26_2017
cd sourcecode_linux/
chmod +x compile_*.txt

./compile_parallel.txt
cp Chargemol_09_26_2017_linux_parallel ${PREFIX}/bin/chargemol
