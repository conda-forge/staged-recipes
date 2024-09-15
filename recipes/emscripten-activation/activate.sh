if [ -z ${CONDA_FORGE_EMSCRIPTEN_ACTIVATED+x} ]; then

    export CONDA_FORGE_EMSCRIPTEN_ACTIVATED=1

    export EMSDK_PYTHON=${CONDA_PREFIX}/bin/python3

    export CONDA_EMSDK_DIR=${CONDA_PREFIX}/opt/emsdk

    # clear all prexisting cmake args / CC / CXX / AR / RANLIB
    export CC="emcc"
    export CXX="em++"
    export AR="emar"
    export RANLIB="emranlib"
    
    export CMAKE_ARGS=""

    # set the emscripten toolchain
    export CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_TOOLCHAIN_FILE=$CONDA_EMSDK_DIR/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake"

    # conda prefix path
    export CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_PREFIX_PATH=$PREFIX"

    # install prefix
    export CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=$PREFIX"

    # find root path mode package
    export CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ON"

    # fpic
    export CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true"

    # useful variables
    export PY_SIDE_LD_FLAGV

    # basics
    export OPTFLAGS_USED="-O2"
    export DBGFLAGS_USED="-g0"

    # basics ld
    export LDFLAGS_BASE="-s MODULARIZE=1 -s LINKABLE=1 -s EXPORT_ALL=1 -s WASM=1 -std=c++14 -s LZ4=1"
    export LDFLAGS_BASE="${OPTFLAGS_USED} ${DBGFLAGS_USED} ${LDFLAGS_BASE}"

    # basics cflags
    export CFLAGS_BASE="-fPIC"
    export CFLAGS_BASE="${OPTFLAGS_USED} ${DBGFLAGS_USED} ${CFLAGS_BASE}"

    # side module
    export SIDE_MODULE_LDFLAGS="${LDFLAGS_BASE} -s SIDE_MODULE=1"
    export SIDE_MODULE_CFLAGS="${CFLAGS_BASE} -I${PREFIX}/include"

    # wasm bigint
    export LDFLAGS="$LDFLAGS -sWASM_BIGINT"

fi
