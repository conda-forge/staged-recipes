#!/bin/bash
set -ex

cd ascii
# the makefiles are only makefile _templates_, but basically functional;
# to avoid use of perl for mkmf, just execute the template and then
# do the installation step manually
make FC=$FC LINKER=$FC LDFLAGS="-L$CONDA_BUILD_SYSROOT/../lib" install -f makefile.gf
cp ./x13as_ascii $PREFIX/bin

cd ../html
make FC=$FC LINKER=$FC LDFLAGS="-L$CONDA_BUILD_SYSROOT/../lib" install -f makefile.gf
cp ./x13as_html $PREFIX/bin
