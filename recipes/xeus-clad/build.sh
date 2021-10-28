#!/bin/bash

perl -i -pe 'if($. == 7) {s//      "-fplugin=${PREFIX}\/lib\/clad.dylib",\n/}'  $SRC_DIR/share/jupyter/kernels/xcpp11/kernel.json.in
perl -i -pe 'if($. == 7) {s//      "-fplugin=${PREFIX}\/lib\/clad.dylib",\n/}'  $SRC_DIR/share/jupyter/kernels/xcpp14/kernel.json.in
perl -i -pe 'if($. == 7) {s//      "-fplugin=${PREFIX}\/lib\/clad.dylib",\n/}'  $SRC_DIR/share/jupyter/kernels/xcpp17/kernel.json.in

cmake -DCMAKE_BUILD_TYPE=Release     \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX    \
      -DCMAKE_INSTALL_LIBDIR=lib     \
      -DDISABLE_ARCH_NATIVE=ON       \
      $SRC_DIR

make install
