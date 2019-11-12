#!/bin/sh
mkdir ../build && cd ../build

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release \
-DBUILD_SHARED_LIBS=ON -DUSE_CIFTI_CODE=ON -DUSE_NIFTI2_CODE=ON $SRC_DIR

make install