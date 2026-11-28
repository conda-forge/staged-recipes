#!/bin/bash
# gaw (xschem-gaw, GTK3 fork) build for conda-forge (linux-64 / linux-aarch64).
#
# pkg-config dependency chain of gtk3 needs the conda-forge meta-packages
# zlib/expat (runtime libzlib/libexpat ship no .pc files) and glib
# (glibconfig.h ships in the glib package, not libglib) - see recipe.yaml.
set -ex

./configure --prefix="${PREFIX}"

make -j${CPU_COUNT:-4} V=1
make -j${CPU_COUNT:-4} install
