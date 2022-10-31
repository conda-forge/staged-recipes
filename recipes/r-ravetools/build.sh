#!/bin/bash
export DISABLE_AUTOBREW=1

# conda-build installation env is different than CRAN, which
# crashes configure (srcdir not found). To solve this issue
# we delete the configure scripts and write our own src/Makevars.
echo "======== Running build.sh ======="

fftw3_cflags=$(pkg-config --cflags fftw3)
fftw3_libs=$(pkg-config --libs fftw3)

# remove configure
rm configure*
rm src/Makevars.in

touch src/Makevars
echo "CXX_STD=CXX11" > src/Makevars
echo "PKG_CPPFLAGS=${fftw3_cflags} -I../inst/include" >> src/Makevars
echo "PKG_LIBS=${fftw3_libs}" >> src/Makevars

${R} CMD INSTALL --build . ${R_ARGS}
