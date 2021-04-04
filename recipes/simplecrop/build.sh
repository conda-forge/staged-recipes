#! /bin/bash

# export FFLAGS="-Wall -Wextra -Wpedantic -std=f2003 -Wimplicit-interface $FFLAGS"

# $FC $FFLAGS src/*Component.f03 src/*CLI.f03 src/Main.f03 -o simplecrop

cp $RECIPE_DIR/CMakeLists.txt src

cd src
for f in *f03; do
  mv $f ${f%.*}.f90
done

mkdir _build
cd _build

cmake ../ -DCMAKE_INSTALL_PREFIX=$PREFIX
make all install
