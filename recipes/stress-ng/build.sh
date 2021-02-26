export BINDIR=${PREFIX}

# Build
make clean
STATIC=1 LDFLAGS="-lm -lc -latomic" make

# Test
#make lite-test

# Install
make install

# Copy over build libs
##find ${BUILD_PREFIX} -type f -name "*.so*" -exec cp {} ${PREFIX} \;
