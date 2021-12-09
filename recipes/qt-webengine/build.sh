set -exou

if [[ $(arch) == "aarch64" || $(uname) == "Darwin" ]]; then
pushd qtwebengine-chromium

# Ensure that Chromium is built using the correct sysroot in Mac
awk 'NR==77{$0="    rebase_path(\"'$CONDA_BUILD_SYSROOT'\", root_build_dir),"}1' chromium/build/config/mac/BUILD.gn > chromium/build/config/mac/BUILD.gn.tmp
rm chromium/build/config/mac/BUILD.gn
mv chromium/build/config/mac/BUILD.gn.tmp chromium/build/config/mac/BUILD.gn

git config user.name 'Anonymous'
git config user.email '<>'

git add -A
git commit -m "Patches"
popd
fi

git submodule init
git submodule set-url src/3rdparty "$SRC_DIR"/qtwebengine-chromium
git submodule set-branch --branch 87-based src/3rdparty
git submodule update

pushd src/3rdparty
git checkout 87-based
git pull
popd

mkdir qtwebengine-build
pushd qtwebengine-build

USED_BUILD_PREFIX=${BUILD_PREFIX:-${PREFIX}}
echo USED_BUILD_PREFIX=${BUILD_PREFIX}

if [[ $(uname) == "Linux" ]]; then
    ln -s ${GXX} g++ || true
    ln -s ${GCC} gcc || true
    ln -s ${USED_BUILD_PREFIX}/bin/${HOST}-gcc-ar gcc-ar || true

    export LD=${GXX}
    export CC=${GCC}
    export CXX=${GXX}

    chmod +x g++ gcc gcc-ar
    export PATH=$PREFIX/bin:${PWD}:${PATH}

    which pkg-config
    export PKG_CONFIG_EXECUTABLE=$(which pkg-config)
    export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/:$BUILD_PREFIX/lib/pkgconfig/

    # Set QMake prefix to $PREFIX
    qmake -set prefix $PREFIX

    qmake QMAKE_LIBDIR=${PREFIX}/lib \
        QMAKE_LFLAGS+="-Wl,-rpath,$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib -L$PREFIX/lib" \
        INCLUDEPATH+="${PREFIX}/include" \
        PKG_CONFIG_EXECUTABLE=$(which pkg-config) \
        ..

    #cat config.log
    #exit 1
    CPATH=$PREFIX/include:$BUILD_PREFIX/src/core/api make -j$(nproc)
    make install
fi

if [[ $(uname) == "Darwin" ]]; then
    export AR=$(basename ${AR})
    export RANLIB=$(basename ${RANLIB})
    export STRIP=$(basename ${STRIP})
    export OBJDUMP=$(basename ${OBJDUMP})
    export CC=$(basename ${CC})
    export CXX=$(basename ${CXX})

    # Let Qt set its own flags and vars
    for x in OSX_ARCH CFLAGS CXXFLAGS LDFLAGS
    do
        unset $x
    done

    # Some test runs 'clang -v', but I do not want to add it as a requirement just for that.
    ln -s "${CXX}" ${HOST}-clang || true
    # For ltcg we cannot use libtool (or at least not the macOS 10.9 system one) due to lack of LLVM bitcode support.
    ln -s "${LIBTOOL}" libtool || true
    # Just in-case our strip is better than the system one.
    ln -s "${STRIP}" strip || true
    chmod +x ${HOST}-clang libtool strip
    # Qt passes clang flags to LD (e.g. -stdlib=c++)
    export LD=${CXX}
    PATH=${PWD}:${PATH}
    # Use xcode-avoidance scripts
    PATH=$PREFIX/bin/xc-avoidance:$PATH

    export APPLICATION_EXTENSION_API_ONLY=NO

    EXTRA_FLAGS=""
    if [[ $(arch) == "arm64" ]]; then
      EXTRA_FLAGS="QMAKE_APPLE_DEVICE_ARCHS=arm64"
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

    # find . -type f -exec sed -i '' -e 's/-Wl,-fatal_warnings//g' {} +
    # sed -i '' -e 's/-Werror//' $PREFIX/mkspecs/features/qt_module_headers.prf

    make -j$CPU_COUNT
    make install
fi

# Post build setup
# ----------------
# Remove static libraries that are not part of the Qt SDK.
pushd "${PREFIX}"/lib > /dev/null
    find . -name "*.a" -and -not -name "libQt*" -exec rm -f {} \;
popd > /dev/null
