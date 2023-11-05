if [[ "$target_platform" == "osx-64" ]]; then
    # They seem to be missing a default value or an option for this
    # in their CMakeLists.txt files
    export CXXFLAGS="$CXXFLAGS -DTARGET_OS_OSX=1"
    export CFLAGS="$CFLAGS -DTARGET_OS_OSX=1"
fi
mkdir build
cd build
cmake ${CMAKE_ARGS}                \
    ..
make -j${CPU_COUNT} VERBOSE=1 V=1
make install
