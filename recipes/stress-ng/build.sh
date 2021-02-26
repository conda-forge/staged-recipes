export DESTDIR=${PREFIX}

# Build
make clean
make

# Test
make lite-test

# Install
make install

# Copy over build libs
cp -r $BUILD_PREFIX $PREFIX
