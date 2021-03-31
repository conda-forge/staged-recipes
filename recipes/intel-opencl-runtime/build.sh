#!/bin/bash
set -ex

# for subpackages, we have named our extracted locations according to the subpackage name
#    That's what this $PKG_NAME is doing - picking the right subfolder to rsync

src="$SRC_DIR/$PKG_NAME"
cp -rv "$src"/* "$PREFIX/"

if [[ "$PKG_NAME" == "intel-opencl-runtime" ]]; then
   # Use conda-forge's opencl loader
   rm -rf $PREFIX/lib/libOpenCL.*
   # Use intel-opencl-clang package
   rm $PREFIX/lib/libcommon_clang.so.$PKG_VERSION
   ln -sf $PREFIX/lib/libcommon_clang.so $PREFIX/lib/libcommon_clang.so.$PKG_VERSION
   # Add an icd file
   mkdir -p $PREFIX/etc/OpenCL/vendors/
   echo "$PREFIX/lib/libintelocl.so" >> $PREFIX/etc/OpenCL/vendors/intel-cpu.icd
fi

# replace old info folder with our new regenerated one
rm -rf "$PREFIX/info"
