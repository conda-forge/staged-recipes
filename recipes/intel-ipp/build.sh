#!/usr/bin/env bash


cd rpm || exit 1

$RECIPE_DIR/extract.py intel-ipp-common-2019.1-144-2019.1-144.noarch.rpm
$RECIPE_DIR/extract.py intel-ipp-st-2019.1-144-2019.1-144.x86_64.rpm

mkdir -p "$PREFIX"/{lib,include}

root_extraction_dir="opt/intel/compilers_and_libraries_2019.1.144/linux/ipp"
ls "$root_extraction_dir"

cp "$root_extraction_dir/include/"*.h \
    "$PREFIX/include"
cp "$root_extraction_dir/lib/intel64_lin/"*.so \
    "$PREFIX/lib"
