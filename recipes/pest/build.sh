#!/usr/bin/env bash

tar xvf ./*.tar

mv 'c:\pest_source' pest_source
chmod a+rwx pest_source
cd pest_source || exit
chmod a+rwx doc edpestex papestex pestex ppestex

# SpeedTest is a unused function that causes a compilation error.
sed '/SpeedTest/d' ip.c > ip.c.tmp
mv ip.c.tmp ip.c

make cppp
make -f pest.mak all
make clean
make -f ppest.mak all
make clean
make -f pestutl1.mak all
make clean
make -f pestutl2.mak all
make clean
make -f pestutl3.mak all
make clean
make -f pestutl4.mak all
make clean
make -f pestutl5.mak all
make clean
make -f pestutl6.mak all
make clean
make -f pestutl7.mak all
make clean
make -f sensan.mak all
make clean
make -f beopest.mak all
make clean

rm cppp  # only used for building, not needed at runtime

mkdir -p "${PREFIX}/bin"
find . -type f -executable -exec cp \{\} "${PREFIX}/bin/" \;

