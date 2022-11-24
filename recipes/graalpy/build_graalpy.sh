#!/bin/bash

set -exo pipefail

if [ `uname` = "Darwin" ]; then
    MACOS="true"
fi

# this needs to be updated when the target python version of graalpy changes
PY_VERSION=3.8

# set up paths for mx build
export MX_DIR=$SRC_DIR/mx
export PATH=$PATH:$MX_DIR
export MX_PRIMARY_SUITE_PATH=$SRC_DIR/graal/vm

# mx ninja build templates hardcode ar, gcc, g++; symlink these to the conda
# compilers
ln -sf $AR $MX_DIR/ar
ln -sf $CC $MX_DIR/gcc
ln -sf $CXX $MX_DIR/g++

# sulong toolchain wrappers are not recognized and cmake is making trouble
# getting them to compile anything. Make sure to use the sysroot flag, and
# symlink build environment objects
export CFLAGS="$CFLAGS --sysroot $CONDA_BUILD_SYSROOT"
export CXXFLAGS="$CXXFLAGS --sysroot $CONDA_BUILD_SYSROOT"
export LDFLAGS="$LDFLAGS --sysroot $CONDA_BUILD_SYSROOT"
export CPATH="$BUILD_PREFIX/include"
export LIBRARY_PATH="$BUILD_PREFIX/lib"
if [ -z "${MACOS}" ]; then
    for filename in $CONDA_BUILD_SYSROOT/../lib/libgcc_s.so*; do
        ln -s $filename $CONDA_BUILD_SYSROOT/lib/
    done
    ln -s $CONDA_BUILD_SYSROOT/../../lib/gcc/x86_64-conda-linux-gnu/*/crtbegin.o $CONDA_BUILD_SYSROOT/lib/
    ln -s $CONDA_BUILD_SYSROOT/../../lib/gcc/x86_64-conda-linux-gnu/*/crtbeginS.o $CONDA_BUILD_SYSROOT/lib/
    ln -s $CONDA_BUILD_SYSROOT/../../lib/gcc/x86_64-conda-linux-gnu/*/crtend.o $CONDA_BUILD_SYSROOT/lib/
    ln -s $CONDA_BUILD_SYSROOT/../../lib/gcc/x86_64-conda-linux-gnu/*/crtendS.o $CONDA_BUILD_SYSROOT/lib/
    ln -s $CONDA_BUILD_SYSROOT/../../lib/gcc/x86_64-conda-linux-gnu/*/libgcc.a $CONDA_BUILD_SYSROOT/lib/
fi

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
if [ -n "${GRAALPY_STANDALONE_BUILD}" ]; then
    export NATIVE_IMAGES=lib:pythonvm,lib:jvmcicompiler,graalvm-native-binutil,graalvm-native-clang,graalvm-native-clang-cl,graalvm-native-clang++,graalvm-native-ld
else
    export NATIVE_IMAGES=lib:jvmcicompiler,graalvm-native-binutil,graalvm-native-clang,graalvm-native-clang-cl,graalvm-native-clang++,graalvm-native-ld
fi
export DISABLE_INSTALLABLES=False

# set correct jdk paths
if [ -z "${MACOS}" ]; then
    export JAVA_HOME=$SRC_DIR/labsjdk
else
    export JAVA_HOME=$SRC_DIR/labsjdk/Contents/Home
fi

# run the build
mx graalvm-show
mx build

if [ -n "${GRAALPY_STANDALONE_BUILD}" ]; then
    # move the standalone build artifact into $PREFIX
    STANDALONE=`mx standalone-home python`
    cp -r $STANDALONE/* $PREFIX

    if [ -z "${MACOS}" ]; then
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
    fi

    # match cpython include folder structure
    ln -sf $PREFIX/include $PREFIX/include/python${PY_VERSION}

    # license is packaged by the build process
    cat $PREFIX/LICENSE_GRAALPY.txt $PREFIX/THIRD_PARTY_LICENSE_GRAALPY.txt > $SRC_DIR/LICENSE_GRAALPY.txt
    rm $PREFIX/LICENSE_GRAALPY.txt $PREFIX/THIRD_PARTY_LICENSE_GRAALPY.txt
else
    GRAALVM=`mx graalvm-home`
    mkdir -p $PREFIX/lib/jvm
    cp -r $GRAALVM $PREFIX/lib/jvm/
    GRAALVM_PREFIX=$PREFIX/lib/jvm/${GRAALVM##*/}

    # symlink binaries
    mkdir -p $PREFIX/bin/
    for i in $GRAALVM_PREFIX/bin/*; do
        if [ -x "$i" ]; then
            ln -sf "$i" $PREFIX/bin/
        fi
    done

    # sulong ensures that the llvm toolchain uses libc++abi.so in the toolchain
    # directory by dynamically making sure it's loaded in its toolchain wrappers,
    # but the conda build cannot know this and complains
    if [ -z "${MACOS}" ]; then
        LIBCXX_RPATH=`patchelf --print-rpath $GRAALVM_PREFIX/lib/llvm/lib/*/libc++.so.1.0`
        if [ -n "$LIBCXX_RPATH" ]; then
            LIBCXX_RPATH="$LIBCXX_RPATH:\$ORIGIN"
        else
            LIBCXX_RPATH="\$ORIGIN"
        fi
        patchelf --set-rpath "$LIBCXX_RPATH" $GRAALVM_PREFIX/lib/llvm/lib/*/libc++.so.1.0
    fi

    # relativize rpath for jvm libs
    if [ -z "${MACOS}" ]; then
        # delete graalvm libraries not required for graalpy
        rm $GRAALVM_PREFIX/lib/libsplashscreen.so
        rm $GRAALVM_PREFIX/lib/libawt_xawt.so
        rm $GRAALVM_PREFIX/lib/libjawt.so
        rm $GRAALVM_PREFIX/lib/libfontmanager.so
        rm $GRAALVM_PREFIX/lib/libjsound.so

        for i in $GRAALVM_PREFIX/lib/*.so; do
            SO_RPATH=`patchelf --print-rpath $i`
            if [ -n "$SO_RPATH" ]; then
                SO_RPATH="$SO_RPATH:\$ORIGIN/server"
            else
                SO_RPATH="\$ORIGIN/server"
            fi
            patchelf --set-rpath "$SO_RPATH" $i
        done
    fi

    # delete linux bits from sulong's llvm toolchain
    if [ -n "${MACOS}" ]; then
        rm -rf $GRAALVM_PREFIX/lib/llvm/lib/clang/*/lib/linux/
    fi

    # match cpython include folder structure
    mkdir -p $PREFIX/include/python${PY_VERSION}/
    mv $GRAALVM_PREFIX/languages/python/include/* $PREFIX/include/python${PY_VERSION}/
    rmdir $GRAALVM_PREFIX/languages/python/include
    ln -sf $PREFIX/include/python${PY_VERSION} $GRAALVM_PREFIX/languages/python/include

    # license is packaged by the build process
    cat $GRAALVM_PREFIX/*LICENSE*.txt $GRAALVM_PREFIX/3rd_party_license*.txt > $SRC_DIR/LICENSE_GRAALPY.txt
fi

# ensure python{PY_VERSION} launcher exists, even though graalpy only ships "python" and "python3"
if [ ! -e "${PREFIX}/bin/python${PY_VERSION}" ]; then
    ln -s "${PREFIX}/bin/graalpy" "${PREFIX}/bin/python${PY_VERSION}"
fi

# ensure site-package folder matches cpython, even if graalpy expects the folder somewhere else
graalpy_expected_site_packages=`$PREFIX/bin/graalpy -c 'import site; print(site.getsitepackages()[0])'`
cpython_expected_site_packages=$PREFIX/lib/python${PY_VERSION}/site-packages
if [ -e "${graalpy_expected_site_packages}" ]; then
    graalpy_expected_site_packages=$(cd ${graalpy_expected_site_packages}; pwd)
fi
if [ -e "${cpython_expected_site_packages}" ]; then
    cpython_expected_site_packages=$(cd ${cpython_expected_site_packages}; pwd)
fi
mkdir -p ${cpython_expected_site_packages}
if [ "${graalpy_expected_site_packages}" != "${cpython_expected_site_packages}" ]; then
    # create a link from where graalpy expects site-packages to the system site-packages
    rm -rf ${graalpy_expected_site_packages}
    mkdir -p $(dirname ${graalpy_expected_site_packages})
    ln -sf ${cpython_expected_site_packages} ${graalpy_expected_site_packages}
fi
