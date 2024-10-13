#!/bin/bash
set -ex

if [[ "$target_platform" == linux-* ]]; then
    # needs to explicitly link libm
    export LDFLAGS="$LDFLAGS -lm"
else
    export LDFLAGS="$LDFLAGS -framework CoreFoundation"
fi
# both platforms need to link libgfortran
export LDFLAGS="$LDFLAGS -lgfortran"

cd ascii
# the makefiles are only makefile _templates_, but basically functional;
# to avoid use of perl for mkmf, just execute the template and then
# do the installation step manually
make FC="$FC $FFLAGS" LINKER=$FC LDFLAGS="$LDFLAGS" install -f makefile.gf
cp ./x13as_ascii $PREFIX/bin

cd ../html
make FC="$FC $FFLAGS" LINKER=$FC LDFLAGS="$LDFLAGS" install -f makefile.gf
cp ./x13as_html $PREFIX/bin
