#!/bin/bash

set -exo pipefail

# this needs to be updated when the target python version of graalpy changes
PY_VERSION=3.8

# set up paths for mx build
export MX_DIR=$SRC_DIR/mx
export PATH=$PATH:$MX_DIR
export MX_PRIMARY_SUITE_PATH=$SRC_DIR/graal/vm

# mx ninja build templates hardcode ar, gcc, g++; symlink these to the conda
# compilers
ln -s $AR $MX_DIR/ar
ln -s $CC $MX_DIR/gcc
ln -s $CXX $MX_DIR/g++

# sulong toolchain wrappers are not recognized and cmake is making trouble
# getting them to compile anything. Make sure to use the sysroot flag, and
# symlink build environment objects
export CFLAGS="$CFLAGS --sysroot $CONDA_BUILD_SYSROOT"
export CXXFLAGS="$CXXFLAGS --sysroot $CONDA_BUILD_SYSROOT"
export LDFLAGS="$LDFLAGS --sysroot $CONDA_BUILD_SYSROOT"
export CPATH="$BUILD_PREFIX/include"
export LIBRARY_PATH="$BUILD_PREFIX/lib"
for filename in $CONDA_BUILD_SYSROOT/../lib/libgcc_s.so*; do
    ln -s $filename $CONDA_BUILD_SYSROOT/lib/
done
ln -s $CONDA_BUILD_SYSROOT/../../lib/gcc/x86_64-conda-linux-gnu/*/crtbegin.o $CONDA_BUILD_SYSROOT/lib/
ln -s $CONDA_BUILD_SYSROOT/../../lib/gcc/x86_64-conda-linux-gnu/*/crtbeginS.o $CONDA_BUILD_SYSROOT/lib/
ln -s $CONDA_BUILD_SYSROOT/../../lib/gcc/x86_64-conda-linux-gnu/*/crtend.o $CONDA_BUILD_SYSROOT/lib/
ln -s $CONDA_BUILD_SYSROOT/../../lib/gcc/x86_64-conda-linux-gnu/*/crtendS.o $CONDA_BUILD_SYSROOT/lib/
ln -s $CONDA_BUILD_SYSROOT/../../lib/gcc/x86_64-conda-linux-gnu/*/libgcc.a $CONDA_BUILD_SYSROOT/lib/

# git init an empty repo inside graal, to force mx to pick graal download as
# siblings dir
git init $SRC_DIR/graal
git -C $SRC_DIR/graal config --local user.name "none"
git -C $SRC_DIR/graal config --local user.email "none@example.org"
git -C $SRC_DIR/graal commit --allow-empty -m "dummy commit"

# set environment variables to build a graalpy distribution taken from the
# released graal/mx/mx.vm/ce env file
export MX_PYTHON=${BUILD_PREFIX}/bin/pypy3
export DYNAMIC_IMPORTS=/compiler,/regex,/sdk,/substratevm,/sulong,/tools,/truffle,graalpython
export COMPONENTS=cmp,cov,dap,dis,gu,gvm,icu4j,ins,insight,insightheap,lg,llp,llrc,llrl,llrn,lsp,nfi-libffi,pbm,pmh,poly,polynative,pro,pyn,pynl,rgx,sdk,tfl,tflm
export NATIVE_IMAGES=lib:pythonvm,lib:jvmcicompiler,graalvm-native-binutil,graalvm-native-clang,graalvm-native-clang-cl,graalvm-native-clang++,graalvm-native-ld
export DISABLE_INSTALLABLES=False

# set correct jdk paths
CONTINUOUS_INTEGRATION=true mx fetch-jdk --to $SRC_DIR --strip-contents-home --jdk-id labsjdk-ce-17
export JAVA_HOME=`echo $SRC_DIR/labsjdk-ce-17*`
export JAVA_OPTS="-Xmx4G"

# run the build
mx graalvm-show
mx build

# move the standalone build artifact into $PREFIX
STANDALONE=`$MX_DIR/mx standalone-home python`
cp -r $STANDALONE/* $PREFIX

# sulong ensures that the llvm toolchain uses libc++abi.so in the toolchain
# directory by dynamically making sure it's loaded in its toolchain wrappers,
# but the conda build cannot know this and complains
LIBCXX_RPATH=`patchelf --print-rpath $PREFIX/lib/llvm-toolchain/lib/*/libc++.so.1.0`
if [ -n "$LIBCXX_RPATH" ]; then
    LIBCXX_RPATH="$LIBCXX_RPATH:\$ORIGIN"
else
    LIBCXX_RPATH="\$ORIGIN"
fi
patchelf --set-rpath "$LIBCXX_RPATH" $PREFIX/lib/llvm-toolchain/lib/*/libc++.so.1.0

# create the site-packages folder to match cpython
mkdir -p $PREFIX/lib/python${PY_VERSION}/site-packages

# match cpython include folder structure
ln -sf $PREFIX/include $PREFIX/include/python${PY_VERSION}

# license is packaged by the build process
cat $PREFIX/LICENSE_GRAALPY.txt $PREFIX/THIRD_PARTY_LICENSE_GRAALPY.txt > $SRC_DIR/LICENSE_GRAALPY.txt
rm $PREFIX/LICENSE_GRAALPY.txt $PREFIX/THIRD_PARTY_LICENSE_GRAALPY.txt
