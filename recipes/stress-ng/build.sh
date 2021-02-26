##export BINDIR=${PREFIX}
##export LDFLAGS=-lrt -lm -lc -latomic
##export STATIC=1

# Build
make clean
make

# Test
make lite-test

# Install
make install

# Copy over build libs
##find ${BUILD_PREFIX} -type f -name "*.so*" -exec cp {} ${PREFIX} \;
