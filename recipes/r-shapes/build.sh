#!/bin/bash
if [[ ${HOST} =~ .*linux.* ]]; then
  X11_CONFIGURE_ARGS="--x-includes=${PREFIX}/include --x-libraries=${BUILD_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib64"
  export LD_LIBRARY_PATH=${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/lib64:${BUILD_PREFIX}/lib
fi
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build . ${R_ARGS}
