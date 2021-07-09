#!/bin/bash

set -ex

echo "Building GCC version $1 ..."

echo "Installing required packages"
pacman --noconfirm -S lndir git subversion tar zip p7zip make patch automake autoconf libtool flex bison gettext-devel sshpass texinfo autogen dejagnu

echo "Current DIR: ${PWD}"

echo "Build destination"
dest="/c/mingw-build"
mkdir -p $dest
rm -rf $dest/*

echo "Building ..."
cd mingw-build-scripts
bash -x ./build --mode=gcc-$1 --buildroot=$dest --enable-languages=c,c++ --jobs=48 --rev=0 --rt-version=v7 --threads=posix --exceptions=seh --arch=x86_64 --logviewer-command=cat --wait-for-logviewer --no-multilib --bootstrap --bin-compress

echo "Done. Results here: $dest"
tree -L 2 --charset=ascii $dest
