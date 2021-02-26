export BINDIR=${PREFIX}
export CFLAGS="$CFLAGS -lm -lc -latomic"

# Build
make clean
STATIC=1 make

# Test
make lite-test

# Install
make install

# Copy over build libs
##find ${BUILD_PREFIX} -type f -name "*.so*" -exec cp {} ${PREFIX} \;
