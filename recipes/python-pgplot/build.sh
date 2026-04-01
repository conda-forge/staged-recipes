#!/bin/bash

set -euxo pipefail

# Build and install giza from source (like CIBW_BEFORE_ALL)
cd /tmp
wget https://github.com/danieljprice/giza/archive/refs/tags/v1.4.2.tar.gz
tar -xzf v1.4.2.tar.gz
cd giza-1.4.2

# Configure and build giza
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

# Update config.sub for ARM64 support
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Download updated config.sub that recognizes arm64-apple-darwin
    wget -O build/config.sub 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD'
    chmod +x build/config.sub
fi

./configure --prefix=${PREFIX} --enable-shared
make -j${CPU_COUNT}
make install

# Ensure pkg-config can find giza
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

# Return to source directory and build python-pgplot
cd ${SRC_DIR}

# Build and install the package
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

# Test that the extension was built correctly
${PYTHON} -c "import ppgplot; print('python-pgplot extension imported successfully')"
${PYTHON} -c "import ppgplot._ppgplot; print('C extension module loaded successfully')"
