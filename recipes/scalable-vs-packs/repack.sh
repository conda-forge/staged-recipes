#!/bin/bash
set -ex

# for subpackages, we have named our extracted locations according to the subpackage name
#    That's what this $PKG_NAME is doing - picking the right subfolder to rsync

# Extracting .conda files since conda-build
for conda_file in `find . -name '*.conda'`; do \
  DIR_NAME=$(dirname $conda_file)
  cph transmute "${conda_file}" .tar.bz2 ;
  rm ${conda_file} ;
  for tar_file in `find . -name '*.tar.bz2'`; do \
    tar xjvf "${tar_file}" -C ${DIR_NAME} ;
    rm ${tar_file}
  done
done

src="$SRC_DIR/$PKG_NAME"
cp -av "$src"/* "$PREFIX/"

# replace old info folder with our new regenerated one
rm -rf "$PREFIX/info"