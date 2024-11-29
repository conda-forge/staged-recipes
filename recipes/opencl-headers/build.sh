cmake -G Ninja ${CMAKE_ARGS} .
ninja -j${CPU_COUNT}
ninja install

ctest

# remove spurious link
rm -rf $PREFIX/include/CL/CL

# move .pc to lib instead of share
mkdir -p $PREFIX/lib/pkgconfig
mv $PREFIX/share/pkgconfig/OpenCL-Headers.pc $PREFIX/lib/pkgconfig/OpenCL-Headers.pc
