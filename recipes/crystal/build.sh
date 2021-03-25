#!/bin/bash
set -xeuo pipefail
IFS=$'\n\t'


mkdir -p $PREFIX/bin $PREFIX/lib $PREFIX/share

# install crystal to compile crystal
wget https://github.com/crystal-lang/crystal/releases/download/1.0.0/crystal-1.0.0-1-linux-x86_64.tar.gz
tar -xf crystal-1.0.0-1-linux-x86_64.tar.gz

crystal_dir=crystal-1.0.0-1
cp $crystal_dir/bin/* $PREFIX/bin/
cp -r $crystal_dir/lib/* $PREFIX/lib/
cp -r $crystal_dir/share/* $PREFIX/share/
cd $PREFIX/lib/crystal/lib
ln -s ../../libpcre.a
ln -s ../../libevent.a
cd -

echo 'puts "Hello World!"' > hello_world.cr
ls -lha
ls -lha $PREFIX/*
$PREFIX/bin/crystal run hello_world.cr


wget https://github.com/crystal-lang/crystal/archive/refs/tags/1.0.0.tar.gz
tar -xf 1.0.0.tar.gz
crystal_src_dir=crystal-1.0.0
cd $crystal_src_dir
ls
make
# make std_spec || true
# make compiler_spec

install -Dm755 ".build/crystal" "$$PREFIX/bin/crystal"
cp -r src "$PREFIX/lib/crystal"
