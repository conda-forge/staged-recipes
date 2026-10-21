#!/usr/bin/env bash

tar xvf ./*.tar

chmod a+rwx pest_source
cd pest_source || exit
chmod a+rwx doc edpestex papestex pestex ppestex

# Don't use 'sed -i' since it is not portable across all platforms. Create
# a temporary file and then move it to the original file instead.

# SpeedTest is a unused function that causes a compilation error.
sed '/SpeedTest/d' ip.c > ip.c.tmp && mv ip.c.tmp ip.c

# OSX does not support static linking, so remove the -static flag from the
# makefiles.
if [[ "$OSTYPE" == "darwin"* ]]; then
    for file in *.mak; do
        sed 's/-static//g' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    done
fi

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
find . -type f -perm -ugo+x -exec cp \{\} "${PREFIX}/bin/" \;
