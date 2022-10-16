#!/bin/bash

set -exo pipefail

# set up paths for mx build
export MX_DIR=$SRC_DIR/mx
export PATH=$PATH:$MX_DIR
export MX_PRIMARY_SUITE_PATH=$SRC_DIR/graal/vm
ln -s $AR $MX_DIR/ar
ln -s $CC $MX_DIR/gcc
ln -s $CXX $MX_DIR/g++

# git init an empty repo inside graal, to force mx to pick graal download as
# siblings dir
git init $SRC_DIR/graal
git -C $SRC_DIR/graal config --local user.name "none"
git -C $SRC_DIR/graal config --local user.email "none@example.org"
git -C $SRC_DIR/graal commit --allow-empty -m "dummy commit"

# set environment variables to build a graalpy distribution taken from the
# released graal/mx/mx.vm/ce env file
export MX_PYTHON=${BUILD_PREFIX}/bin/python
export DYNAMIC_IMPORTS=/compiler,/regex,/sdk,/substratevm,/sulong,/tools,/truffle,graalpython
export COMPONENTS=cmp,cov,dap,dis,gu,gvm,icu4j,ins,insight,insightheap,lg,llp,llrc,llrl,llrn,lsp,nfi-libffi,pbm,pmh,poly,polynative,pro,pyn,pynl,rgx,sdk,tfl,tflm
export NATIVE_IMAGES=lib:pythonvm,lib:jvmcicompiler,graalvm-native-binutil,graalvm-native-clang,graalvm-native-clang-cl,graalvm-native-clang++,graalvm-native-ld
export DISABLE_INSTALLABLES=False

# set correct jdk paths
CONTINUOUS_INTEGRATION=true mx fetch-jdk --to $SRC_DIR --strip-contents-home --jdk-id labsjdk-ce-17
export JAVA_HOME=`echo $SRC_DIR/labsjdk-ce-17*`

# run the build
mx graalvm-show
mx build

# move the standalone build artifact into $PREFIX
STANDALONE=`$MX_DIR/mx standalone-home python`
cp -r $STANDALONE/* $PREFIX

# create the site-packages folder to match cpython
PY_VERSION=$(echo $PKG_NAME | cut -c 8-)
mkdir -p $PREFIX/lib/python${PY_VERSION}/site-packages

# match cpython include folder structure
ln -sf $PREFIX/include $PREFIX/include/python${PY_VERSION}

# license is packaged by the build process
cat $PREFIX/LICENSE_GRAALPY.txt $PREFIX/THIRD_PARTY_LICENSE_GRAALPY.txt > $SRC_DIR/LICENSE_GRAALPY.txt
rm $PREFIX/LICENSE_GRAALPY.txt $PREFIX/THIRD_PARTY_LICENSE_GRAALPY.txt
