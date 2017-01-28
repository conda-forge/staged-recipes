#! /bin/bash

set -e

if [ -n "$OSX_ARCH" ] ; then
    subtype=actually_osx
else
    subtype=gfortran_gcc
fi

./makemake . linux $subtype
for f in png.h pngconf.h pnglibconf.h zlib.h zconf.h ; do
    ln -s $PREFIX/include/$f $f
done
make all libcpgplot.a

mkdir -p $PREFIX/bin $PREFIX/lib $PREFIX/include/pgplot $PREFIX/share/pgplot
cp -a pgxwin_server $PREFIX/bin/
cp -a libcpgplot.a libpgplot.a libpgplot$SHLIB_EXT $PREFIX/lib/
cp -a grfont.dat rgb.txt $PREFIX/share/pgplot/
cp -a cpgplot.h grpckg1.inc pgplot.inc $PREFIX/include/pgplot/

# NOTE: do not delete .a files! They're what we provide!
