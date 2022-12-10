#!/bin/sh
set -exou

# Clean config for dirty builds
# -----------------------------
if [[ -d qt-build ]]; then
  rm -rf qt-build
fi

mkdir qt-build
pushd qt-build

USED_BUILD_PREFIX=${BUILD_PREFIX:-${PREFIX}}
MAKE_JOBS=$CPU_COUNT
export NINJAFLAGS="-j${MAKE_JOBS}"

# For QDoc
export LLVM_INSTALL_DIR=${PREFIX}

# Remove the full path from CXX etc. If we don't do this
# then the full path at build time gets put into
# mkspecs/qmodule.pri and qmake attempts to use this.
export AR=$(basename ${AR})
export RANLIB=$(basename ${RANLIB})
export STRIP=$(basename ${STRIP})
export OBJDUMP=$(basename ${OBJDUMP})
export CC=$(basename ${CC})
export CXX=$(basename ${CXX})

if [[ $(uname) == "Linux" ]]; then
    ln -s ${GXX} g++ || true
    ln -s ${GCC} gcc || true
    # Needed for -ltcg, it we merge build and host again, change to ${PREFIX}
    ln -s ${USED_BUILD_PREFIX}/bin/${HOST}-gcc-ar gcc-ar || true

    export LD=${GXX}
    export CC=${GCC}
    export CXX=${GXX}
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/lib64/pkgconfig/"
    chmod +x g++ gcc gcc-ar
    export PATH=${PWD}:${PATH}

    qmake -set prefix $PREFIX
    qmake QMAKE_LIBDIR=${PREFIX}/lib \
        QMAKE_LFLAGS+="-Wl,-rpath,$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib -L$PREFIX/lib" \
        INCLUDEPATH+="${PREFIX}/include" \
        PKG_CONFIG_EXECUTABLE=$(which pkg-config) \
        ..

    CPATH=$PREFIX/include:$BUILD_PREFIX/src/core/api make -j$CPU_COUNT
    make install
fi

if [[ ${HOST} =~ .*darwin.* ]]; then
    # Let Qt set its own flags and vars
    unset OSX_ARCH CFLAGS CXXFLAGS LDFLAGS

    # Qt passes clang flags to LD (e.g. -stdlib=c++)
    export LD=${CXX}

    # Use xcode-avoidance scripts provided by qt-main so that the build can
    # run with just the command-line tools, and not full XCode, installed.
    export PATH=$PREFIX/bin/xc-avoidance:$PATH

    export APPLICATION_EXTENSION_API_ONLY=NO

    EXTRA_FLAGS=""
    if [[ $(arch) == "arm64" ]]; then
      EXTRA_FLAGS="QMAKE_APPLE_DEVICE_ARCHS=arm64"
    fi

    if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
      # The python2_hack does not know about _sysconfigdata_arm64_apple_darwin20_0_0, so unset the data name
      unset _CONDA_PYTHON_SYSCONFIGDATA_NAME
    fi

    # Set QMake prefix to $PREFIX
    qmake -set prefix $PREFIX

    # sed -i '' -e 's/-Werror//' $PREFIX/mkspecs/features/qt_module_headers.prf

    qmake QMAKE_LIBDIR=${PREFIX}/lib \
        INCLUDEPATH+="${PREFIX}/include" \
        CONFIG+="warn_off" \
        QMAKE_CFLAGS_WARN_ON="-w" \
        QMAKE_CXXFLAGS_WARN_ON="-w" \
        QMAKE_CFLAGS+="-Wno-everything" \
        QMAKE_CXXFLAGS+="-Wno-everything" \
        $EXTRA_FLAGS \
        QMAKE_LFLAGS+="-Wno-everything -Wl,-rpath,$PREFIX/lib -L$PREFIX/lib" \
        PKG_CONFIG_EXECUTABLE=$(which pkg-config) \
        ..

    make -j$CPU_COUNT
    make install
fi

# Post build setup
# ----------------
# Remove static libraries that are not part of the Qt SDK.
pushd "${PREFIX}"/lib > /dev/null
    find . -name "*.a" -and -not -name "libQt*" -exec rm -f {} \;
popd > /dev/null
