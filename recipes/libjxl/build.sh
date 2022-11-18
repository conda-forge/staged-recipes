set -ex

if [[ "${target_platform}" == linux-* ]]
then
    # librt is required before glibc 2.17
    LDFLAGS="-lrt ${LDFLAGS}"
    # https://github.com/google/highway/pull/524#issuecomment-1025676250
    CXXFLAGS="-D__STDC_FORMAT_MACROS ${CXXFLAGS}"
fi
if [[ "${target_platform}" == osx-* ]]
then
    # Sized deallocation requires MacOS SDK 10.12+
    # https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="-D_LIBCPP_DISABLE_AVAILABILITY ${CXXFLAGS}"
fi

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_FIND_FRAMEWORK:STRING=NEVER \
    -DCMAKE_FIND_APPBUNDLE:STRING=NEVER \
    -DBUILD_TESTING:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DJPEGXL_ENABLE_TOOLS:BOOL=ON \
    -DJPEGXL_ENABLE_DOXYGEN:BOOL=OFF \
    -DJPEGXL_ENABLE_MANPAGES:BOOL=OFF \
    -DJPEGXL_ENABLE_BENCHMARK:BOOL=OFF \
    -DJPEGXL_ENABLE_EXAMPLES:BOOL=OFF \
    -DJPEGXL_BUNDLE_LIBPNG:BOOL=OFF \
    -DJPEGXL_ENABLE_SJPEG:BOOL=OFF \
    -DJPEGXL_ENABLE_SKCMS:BOOL=ON \
    -DJPEGXL_STATIC:BOOL=OFF \
    -DJPEGXL_FORCE_SYSTEM_BROTLI:BOOL=ON \
    -DJPEGXL_FORCE_SYSTEM_HWY:BOOL=ON \
    ..
cmake --build . -j${CPU_COUNT} --target install
