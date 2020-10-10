# Configure
./configure --disable-dependency-tracking --prefix=${PREFIX} --disable-examples --disable-sdltest

# Build step
make -j$CPU_COUNT

# Install step
make install
