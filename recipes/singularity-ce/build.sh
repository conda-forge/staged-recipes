#!/bin/bash
set -xeuf

# Workaround for travis permissions errors which end up creating very verbose log output
if [[ $(uname -m) == "ppc64le" ]]; then
    export GOPATH=${TMPDIR:-/tmp}/gopath
    mkdir -p "${GOPATH}"
fi

pushd src/github.com/sylabs/${PKG_NAME}

# The "starter" binary inherits the stack from "singularity" meaning FORTIFY_SOURCE cannot be used
CGO_CPPFLAGS=$(echo "${CGO_CPPFLAGS}" | sed -E 's@FORTIFY_SOURCE=[0-9]@FORTIFY_SOURCE=0@g')
export CGO_CPPFLAGS

# configure
./mconfig \
  -P release-stripped \
  --without-suid \
  -p "${PREFIX}" \
  -c "${CC}" \
  -x "${CXX}"

# build
pushd builddir
export LD_LIBRARY_PATH=${PREFIX}/lib
make

# install
make install

# Make Empty session dir
mkdir -p $PREFIX/var/singularity/mnt/session
touch $PREFIX/var/singularity/mnt/session/.mkdir
