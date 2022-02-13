#!/bin/bash
set -ex

src="$SRC_DIR/$PKG_NAME"
mkdir -p $PREFIX/lib/intel-ocl-cpu

# Move to intel-ocl-cpu to avoid clashes with intel-opencl-clang
cp -rv "$src/lib/"* "$PREFIX/lib/intel-ocl-cpu/"

for f in $PREFIX/lib/intel-ocl-cpu/*.so.*; do
  if [[ ! -L $f ]]; then
    patchelf --force-rpath --set-rpath '$ORIGIN/:$ORIGIN/../' $f
  fi
done

# Use conda-forge's opencl loader
rm -rf $PREFIX/lib/intel-ocl-cpu/libOpenCL.*

# symlink libtbb to intel-ocl-cpu dir
for f in $PREFIX/lib/libtbbmalloc.so* $PREFIX/lib/libtbb.so* $PREFIX/lib/libxml2.so* $PREFIX/lib/libz.so*; do
  if [[ -L $f ]]; then
    ln -sf ../$(basename $f) $PREFIX/lib/intel-ocl-cpu/$(basename $f)
  fi
done

# Add an icd file
mkdir -p $PREFIX/etc/OpenCL/vendors/
echo "$PREFIX/lib/intel-ocl-cpu/libintelocl.so" >> $PREFIX/etc/OpenCL/vendors/intel-ocl-cpu.icd
