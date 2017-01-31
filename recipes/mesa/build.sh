#!/bin/bash

# DRI drivers depend on newer Linux kernels and would be probably useless or hard to use because
# X.Org server looks for drivers on hard coded paths.
# So just build gallium software drivers
./configure \
    --prefix="$PREFIX" \
    --with-llvm-prefix="$PREFIX" \
    --disable-egl \
    --disable-opencl \
    --disable-xvmc \
    --disable-llvm-shared-libs \
    --disable-gbm \
    --disable-dri \
    --disable-dri3 \
    --enable-gallium-llvm \
    --with-gallium-drivers=swrast \
    --enable-gles1 \
    --enable-gles2
make -j${CPU_COUNT}
make install

# Copy activate/deactivate scripts
mkdir -p "$PREFIX/etc/conda/activate.d"
mkdir -p "$PREFIX/etc/conda/deactivate.d"
cp $RECIPE_DIR/activate-* $PREFIX/etc/conda/activate.d/
cp $RECIPE_DIR/deactivate-* $PREFIX/etc/conda/deactivate.d/
