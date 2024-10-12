#!/bin/bash
set -ex

if [[ "$target_platform" == linux-* ]]; then
    # where libquadmath is found in our setup
    export LDFLAGS="-L$CONDA_BUILD_SYSROOT/../lib"
    # needs to explicitly link glibc
    export LDFLAGS="-lc -L$CONDA_BUILD_SYSROOT/lib64"
else
    export LDFLAGS="-framework CoreFoundation"
fi
# need to link to libgfortran
export LDFLAGS="$LDFLAGS -lgfortran"

cd ascii
# the makefiles are only makefile _templates_, but basically functional;
# to avoid use of perl for mkmf, just execute the template and then
# do the installation step manually
make FC=$FC LINKER=$BUILD_PREFIX/bin/ld LDFLAGS="$LDFLAGS" install -f makefile.gf
cp ./x13as_ascii $PREFIX/bin

cd ../html
make FC=$FC LINKER=$BUILD_PREFIX/bin/ld LDFLAGS="$LDFLAGS" install -f makefile.gf
cp ./x13as_html $PREFIX/bin
