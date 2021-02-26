##export BINDIR=${PREFIX}
##export LDFLAGS=-lrt -lm -lc -latomic
##export STATIC=1

# Build
make clean
make

# Test
#make lite-test

# Install
DESTDIR=${PREFIX} make install

# Copy over build libs
cp -r _build_env/lib/ ${PREFIX}/
##find ${BUILD_PREFIX} -type f -name "*.so*" -exec cp {} ${PREFIX} \;
