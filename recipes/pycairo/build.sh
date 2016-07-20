#!/usr/bin/env bash

# Ensure we are not using MacPorts, but the native OS X compilers
export PATH=/bin:/sbin:/usr/sbin:/usr/bin:/usr/local/bin

# This is really important. Conda build sets the deployment target to 10.5 and
# this seems to be the main reason why the build environment is different in
# conda compared to compiling on the command line. Linking against libc++ does
export MACOSX_DEPLOYMENT_TARGET="10.10"
export OS=osx-64

export ACLOCAL_FLAGS="-I /usr/local/Cellar/pkg-config/0.28/share/aclocal/"
export LIBTOOLIZE=glibtoolize

# Seems that sometimes this is required
chmod -R 777 .*

${PREFIX}/bin/python setup.py install

exit 0
