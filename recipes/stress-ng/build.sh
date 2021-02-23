export DESTDIR=${PREFIX}

# Build
make clean
make

# Test
make lite-test

# Install
make install
