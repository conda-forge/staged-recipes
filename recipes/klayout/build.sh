#!/bin/bash

set -e
set -x

# Despite specifying QMAKE_CXX in expert mode, qmake still requires
# "g++" during the bootstrapping process to obtain gcc paths.
# Therefore, we create a temporary link named "g++"
mkdir temp_bin
cd temp_bin
ln -s $GXX g++
cd ..
export PATH=$(pwd)/temp_bin:$PATH

# Identify OS
UNAME_OUT="$(uname -s)"
if [ "${UNAME_OUT}" = "Linux" ]; then
    OS=Linux
elif [ "${UNAME_OUT}" = "Darwin" ]; then
    OS=Mac
else
    OS="${UNAME_OUT}"
    echo "Unknown OS: ${OS}"
fi

# Set binary and library extensions based on OS
if [[ $OS == "Linux" ]]; then
    bin_ext=""
    lib_ext=".so"
elif [[ $OS == "Mac" ]]; then
    bin_ext=".app"
    lib_ext=".dylib"

    # Modify build system files to use conda's sysroot and deployment target
    cd ${PREFIX}
    default_post_prf="mkspecs/features/mac/default_post.prf"
    sdk_prf="mkspecs/features/mac/sdk.prf"

    # Replace sysroot and deployment target in default_post.prf
    grep -q -- '-isysroot $$sysroot_path $$version_min_flag' ${default_post_prf} && flag="-isysroot $$sysroot_path $$version_min_flag" || flag="-isysroot $$QMAKE_MAC_SDK_PATH $$version_min_flag"
    sed "s|${flag}|-isysroot '$CONDA_BUILD_SYSROOT' -mmacosx-version-min='$MACOSX_DEPLOYMENT_TARGET'|g" ${default_post_prf} > ${default_post_prf}.bkp
    mv ${default_post_prf}.bkp ${default_post_prf}

    # Replace sysroot in sdk.prf
    sed "s|^QMAKE_MAC_SDK_PATH =.*|QMAKE_MAC_SDK_PATH = \"$CONDA_BUILD_SYSROOT\"|g" ${sdk_prf} > ${sdk_prf}.bkp
    mv ${sdk_prf}.bkp ${sdk_prf}
    cd - &> /dev/null
fi

# Build KLayout
cd ${SRC_DIR}
./build.sh -build "${SRC_DIR}/build" -python "${PYTHON}" -expert -without-qtbinding -libpng -libexpat -dry-run

cd ${SRC_DIR}/build
make V=1 -j$CPU_COUNT
make V=1 install

# Copy binaries, libraries, and plugins
cd ${SRC_DIR}/bin-release
cp -a klayout${bin_ext} strm* ${PREFIX}/bin/
cp -a *${lib_ext}* pymod *_plugins ${PREFIX}/lib/

# Add symlink for macOS
if [[ $OS == "Mac" ]]; then
    cd ${PREFIX}/bin/
    ln -s klayout${bin_ext}/Contents/MacOS/klayout .
    cd ${SRC_DIR}
    cp -a build/pymod/*${lib_ext}* ${PREFIX}/lib/pymod/
fi
