#!/usr/bin/env bash
set -euf

# We unpack under the gopath directory
pushd gopath

# Upstream resets the PATH internally in their Makefile.
# It does not work for us.
cockroach=$(pwd)/src/github.com/cockroachdb/cockroach
mkdir -p ${cockroach}/bin
export PATH=${cockroach}/bin:${PATH}

# We only install the OSS version of cockroach. The CCL version is not free.
# Upstream's makefile is complicated and our patch may have exposed some
# build dependency issues. Do not multi-thread.
make -j1 -C ${cockroach} \
  install-oss \
  prefix=$PREFIX \
  BUILDTYPE=release \
  BUILDCHANNEL=source-archive \
  BUILDINFO_TAG=${PKG_VERSION} \
  EXTRA_XCMAKE_FLAGS="-DCMAKE_PREFIX_PATH=$PREFIX"
