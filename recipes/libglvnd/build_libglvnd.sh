set -ex
ninja -C builddir install
rm -rf ${PREFIX}/include
rm -rf ${PREFIX}/lib/pkgconfig
