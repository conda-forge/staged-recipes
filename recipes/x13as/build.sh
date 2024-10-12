#!/bin/bash
set -ex

# in contrast to the usual build orchestrators (which pass LDFLAGS to the
# compiler), the hand-spun upstream build script passes them directly to the
# linker, so strip the `-Wl,...` bits that are meant to tell the compiler to
# forward to the linker (but which make no sense for the linker itself)
export LDFLAGS="$(echo $LDFLAGS | sed 's/-Wl,//g')"
# to help find libgfortran (osx) and libgcc_s (linux)
export LDFLAGS="-L$PREFIX/lib"

if [[ "$target_platform" == linux-* ]]; then
    # where libquadmath is found in our setup
    export LDFLAGS="$LDFLAGS -L$CONDA_BUILD_SYSROOT/../lib"
    # needs to explicitly link glibc & libm
    export LDFLAGS="$LDFLAGS -L$CONDA_BUILD_SYSROOT/lib64 -lc -lm"
    # also needs compiler runtime
    export LDFLAGS="$LDFLAGS -rpath=$PREFIX/lib -lgcc_s"
else
    export LDFLAGS="$LDFLAGS -framework CoreFoundation"
fi
# both platforms need to link libgfortran
export LDFLAGS="$LDFLAGS -lgfortran"

cd ascii
# the makefiles are only makefile _templates_, but basically functional;
# to avoid use of perl for mkmf, just execute the template and then
# do the installation step manually
make FC="$FC $FFLAGS" LINKER=$BUILD_PREFIX/bin/ld LDFLAGS="$LDFLAGS" install -f makefile.gf
cp ./x13as_ascii $PREFIX/bin

cd ../html
make FC="$FC $FFLAGS" LINKER=$BUILD_PREFIX/bin/ld LDFLAGS="$LDFLAGS" install -f makefile.gf
cp ./x13as_html $PREFIX/bin
