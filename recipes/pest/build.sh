#!/usr/bin/env bash

tar xvf ./*.tar

chmod a+rwx pest_source
cd pest_source || exit
chmod a+rwx doc edpestex papestex pestex ppestex

# SpeedTest is a unused function that causes a compilation error.
# Don't use 'sed -i' because it is not portable across linux and OSX. Instead,
# use a temporary file and move it back to the original file.
sed '/SpeedTest/d' ip.c > tmpip.c
mv tmpip.c ip.c

# OSX does not support static linking, so remove the -static flag from the
# makefiles.
if [[ "$OSTYPE" == "darwin"* ]]; then
    for f in *.mak; do
        sed 's/-static//g' "$f" > tmp"$f"
        mv tmp"$f" "$f"
    done
fi

# Compile
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

# Install
rm cppp  # Only needed when building.

mkdir -p "${PREFIX}/bin"
find . -type f -perm -ugo+x -exec cp \{\} "${PREFIX}/bin/" \;
