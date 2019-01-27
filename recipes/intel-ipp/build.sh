#!/usr/bin/env bash

extract() {
    package_path="$1"; shift
    rpm2cpio "$package_path" | gunzip | cpio -idmv
}

cd rpm || exit 1

extract intel-ipp-common-2019.1-144-2019.1-144.noarch.rpm
extract intel-ipp-st-2019.1-144-2019.1-144.x86_64.rpm

mkdir -p "$PREFIX"/{lib,include}

root_extraction_dir="opt/intel/compilers_and_libraries_2019.1.144/linux/ipp"
ls "$root_extraction_dir"

cp "$root_extraction_dir/include/"* \
    "$PREFIX/include"
cp -r "$root_extraction_dir/lib/intel64_lin/"* \
    "$PREFIX/lib"
