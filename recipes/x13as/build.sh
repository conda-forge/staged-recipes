#!/bin/bash
set -ex

if [[ "$target_platform" == linux-* ]]; then
    # needs to explicitly link libm
    export LDFLAGS="$LDFLAGS -lm"
else
    export LDFLAGS="$LDFLAGS -framework CoreFoundation"
fi

mkdir -p $PREFIX/bin

cd ascii
# Link in shared instead of static
sed -i.bak 's/-static //g' makefile.gf
# the makefiles are only makefile _templates_, but basically functional;
# to avoid use of perl for mkmf, just execute the template and then
# do the installation step manually
make FC="$FC $FFLAGS" LINKER=$FC LDFLAGS="$LDFLAGS" install -f makefile.gf
cp ./x13as_ascii $PREFIX/bin

cd ../html
sed -i.bak 's/-static //g' makefile.gf
make FC="$FC $FFLAGS" LINKER=$FC LDFLAGS="$LDFLAGS" install -f makefile.gf
cp ./x13as_html $PREFIX/bin
