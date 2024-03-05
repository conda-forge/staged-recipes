set -ex
CXXFLAGS="-D__STDC_FORMAT_MACROS ${CXXFLAGS}"

mkdir build
cd build
cmake \
    -DCMAKE_BUILD_TYPE=Release     \
    -DJPEGXL_ENABLE_TOOLS=OFF      \
    -DBUILD_TESTING=OFF            \
    -DBUILD_SHARED_LIBS=ON         \
    -DJPEGXL_ENABLE_VIEWERS=OFF    \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    -DJPEGXL_FORCE_SYSTEM_BROTLI=ON \
    -DJPEGXL_FORCE_SYSTEM_HWY=ON   \
    -DJPEGXL_FORCE_SYSTEM_LCMS2=ON \
    -DJPEGXL_ENABLE_SJPEG=OFF      \
    -DCMAKE_FIND_FRAMEWORK=LAST    \
    -DJPEGXL_BUNDLE_LIBPNG=OFF     \
    -DJPEGXL_ENABLE_MANPAGES=OFF   \
    -DJPEGXL_ENABLE_BENCHMARK=OFF  \
    -DJPEGXL_ENABLE_EXAMPLES=OFF   \
    -DJPEGXL_BUNDLE_GFLAGS=OFF     \
    -DJPEGXL_ENABLE_JNI=OFF        \
    -DJPEGXL_ENABLE_OPENEXR=OFF    \
    -DJPEGXL_ENABLE_SKCMS=OFF      \
    ..


make VERBOSE=1 V=1 -j${CPU_COUNT}
make install
