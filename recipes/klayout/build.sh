#!/bin/bash





#!/bin/bash

set -e
set -x

# Identify OS
UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     OS=Linux;;
    Darwin*)    OS=Mac;;
    *)          OS="${UNAME_OUT}"
                echo "Unknown OS: ${OS}"
                exit;;
esac

if [[ $OS == "Linux" ]]; then
    bin_ext=""
    lib_ext=".so"
elif [[ $OS == "Mac" ]]; then
    export bin_ext=".app"
    export lib_ext=".dylib"
    cd ${PREFIX}
    if grep -q -- '-isysroot $$sysroot_path $$version_min_flag' mkspecs/features/mac/default_post.prf; then
        sed 's|-isysroot $$sysroot_path $$version_min_flag|-isysroot '$CONDA_BUILD_SYSROOT' -mmacosx-version-min='$MACOSX_DEPLOYMENT_TARGET'|g' mkspecs/features/mac/default_post.prf > mkspecs/features/mac/default_post.prf.bkp
        mv mkspecs/features/mac/default_post.prf.bkp mkspecs/features/mac/default_post.prf
    elif grep -q -- '-isysroot $$QMAKE_MAC_SDK_PATH $$version_min_flag' mkspecs/features/mac/default_post.prf; then
        sed 's|-isysroot $$QMAKE_MAC_SDK_PATH $$version_min_flag|-isysroot '$CONDA_BUILD_SYSROOT' -mmacosx-version-min='$MACOSX_DEPLOYMENT_TARGET'|g' mkspecs/features/mac/default_post.prf > mkspecs/features/mac/default_post.prf.bkp
        mv mkspecs/features/mac/default_post.prf.bkp mkspecs/features/mac/default_post.prf
    fi
    sed 's|^QMAKE_MAC_SDK_PATH =.*|QMAKE_MAC_SDK_PATH = "'$CONDA_BUILD_SYSROOT'"|g' mkspecs/features/mac/sdk.prf > mkspecs/features/mac/sdk.prf.bkp
    mv mkspecs/features/mac/sdk.prf.bkp mkspecs/features/mac/sdk.prf
fi

cd ${SRC_DIR}
./build.sh -build "${SRC_DIR}/build" -python "${PYTHON}" -expert -without-qtbinding -libpng -libexpat -dry-run

cd ${SRC_DIR}/build
make V=1 -j$CPU_COUNT
make V=1 install

cd ${SRC_DIR}/bin-release
cp -a klayout${bin_ext} strm* ${PREFIX}/bin/
cp -a *${lib_ext}* pymod *_plugins ${PREFIX}/lib/

if [[ $OS == "Mac" ]]; then
    # Add a symlink to allow it to run from the command line
    cd ${PREFIX}/bin/
    ln -s klayout${bin_ext}/Contents/MacOS/klayout .
    cd ${SRC_DIR}
    cp -a build/pymod/*${lib_ext}* ${PREFIX}/lib/pymod/
fi
