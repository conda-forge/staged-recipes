#!/bin/bash
# libtool produces hardcod path! https://github.com/conda-forge/libtool-feedstock/issues/18
# So let's do it ourselves.
name="libtool-2.4.6"
filename="${name}.tar.xz"
url="https://ftp.gnu.org/gnu/libtool/${filename}"
sha256="7c87a8c2c8c0fc9cd5019e402bed4292462d00a718a7cd5f11218153bf28b26f"

# Downloading glibtool
echo "Downloading glibtool from https://ftp.gnu.org/gnu/libtool/${filename}"
curl -o ${filename} ${url}

# Verify sha256
if ! echo "${sha256}  ${filename}" | shasum -a 256 -c -; then
    echo "libtool checksum failed" >&2
    exit 1
fi

# Extract tar file
tar xvf ${filename}

# Apply patch and build libtool
_return_dir=`pwd`
cd ${name}

LIBTOOL_INSTALL=$(pwd)/libtool_install
mkdir -p $LIBTOOL_INSTALL



LIBTOOL_INSTALL=$(pwd)/libtool_install
export HELP2MAN=$(which true)
export M4=m4

./configure --prefix=${LIBTOOL_INSTALL}

make -j${CPU_COUNT} ${VERBOSE_AT} && make install

find $LIBTOOL_INSTALL -name '*.la' -delete
export LIBTOOL=${LIBTOOL_INSTALL}/bin/libtool
export LIBTOOLIZE=${LIBTOOL_INSTALL}/bin/libtoolize

cd $_return_dir

make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"  MACOSX_DEPLOYMENT_TARGET=10.9

make install
