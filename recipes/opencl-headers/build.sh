cmake -G Ninja ${CMAKE_ARGS} .
ninja -j${CPU_COUNT}
ninja install

ctest

# Mostly for macOS compat
ln -s $PREFIX/include/CL $PREFIX/include/OpenCL

# move .pc to lib instead of share
mkdir -p $PREFIX/lib/pkgconfig
mv $PREFIX/share/pkgconfig/OpenCL-Headers.pc $PREFIX/lib/pkgconfig/OpenCL-Headers.pc
