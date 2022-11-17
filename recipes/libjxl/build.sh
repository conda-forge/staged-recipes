set -ex

# librt is required before glibc 2.17
if [[ "${target_platform}" == linux-* ]]; then
    LDFLAGS="-lrt ${LDFLAGS}"
fi
# https://github.com/google/highway/pull/524#issuecomment-1025676250
CXXFLAGS="-D__STDC_FORMAT_MACROS ${CXXFLAGS}"
# Sized deallocation requires MacOS SDK 10.12+
# https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

mkdir build
cd build

ls -l "$PREFIX/include"

cmake ${CMAKE_ARGS} \
    -DCMAKE_FIND_ROOT_PATH="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
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
