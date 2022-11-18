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
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_FIND_FRAMEWORK=NEVER \
    -DCMAKE_FIND_APPBUNDLE=NEVER \
    -DBUILD_TESTING=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DJPEGXL_ENABLE_TOOLS=ON \
    -DJPEGXL_ENABLE_DOXYGEN=OFF \
    -DJPEGXL_ENABLE_MANPAGES=OFF \
    -DJPEGXL_ENABLE_BENCHMARK=OFF \
    -DJPEGXL_ENABLE_EXAMPLES=OFF \
    -DJPEGXL_BUNDLE_LIBPNG=OFF \
    -DJPEGXL_ENABLE_SJPEG=OFF \
    -DJPEGXL_ENABLE_SKCMS=ON \
    -DJPEGXL_STATIC=OFF \
    -DJPEGXL_FORCE_SYSTEM_BROTLI=ON \
    -DJPEGXL_FORCE_SYSTEM_HWY=ON \
    ..
cmake --build . -j${CPU_COUNT} --target install
