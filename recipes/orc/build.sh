mkdir -p build
cd build

declare -a _CMAKE_EXTRA_CONFIG
if [[ ${HOST} =~ .*darwin.* ]]; then
    if [[ ${_XCODE_BUILD} == yes ]]; then
        _CMAKE_EXTRA_CONFIG+=(-G'Xcode')
        _CMAKE_EXTRA_CONFIG+=(-DCMAKE_OSX_ARCHITECTURES=x86_64)
        _CMAKE_EXTRA_CONFIG+=(-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT})
        _VERBOSE=""
    fi
    unset MACOSX_DEPLOYMENT_TARGET
    export MACOSX_DEPLOYMENT_TARGET
    _CMAKE_EXTRA_CONFIG+=(-DCMAKE_AR=${AR})
    _CMAKE_EXTRA_CONFIG+=(-DCMAKE_RANLIB=${RANLIB})
    _CMAKE_EXTRA_CONFIG+=(-DCMAKE_LINKER=${LD})
fi
if [[ ${HOST} =~ .*linux.* ]]; then
    CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++11}"
    # I hate you so much CMake.
    LIBPTHREAD=$(find ${PREFIX} -name "libpthread.so")
    _CMAKE_EXTRA_CONFIG+=(-DPTHREAD_LIBRARY=${LIBPTHREAD})
fi

CPPFLAGS="${CPPFLAGS} -Wl,-rpath,$PREFIX/lib"

cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_JAVA=False \
    -DLZ4_HOME=$PREFIX \
    -DZLIB_HOME=$PREFIX \
    -DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
    -DProtobuf_ROOT=$PREFIX \
    -DPROTOBUF_HOME=$PREFIX \
    -DSNAPPY_HOME=$PREFIX \
    -DBUILD_LIBHDFSPP=NO \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_C_COMPILER=$(type -p ${CC})     \
    -DCMAKE_CXX_COMPILER=$(type -p ${CXX})  \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    "${_CMAKE_EXTRA_CONFIG[@]}" \
    -GNinja ..

ninja
ninja install
