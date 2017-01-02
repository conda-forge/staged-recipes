#! /bin/bash

set -e

# Temporary builder environment diagnostics.

echo "============================================"
env |sort
echo "============================================"

# Sigh, the easiest option is to just compile it all ourselves.

FFLAGS="-g -O -fno-automatic -Wall -fPIC"
CFLAGS="-g -O -Wall -fPIC"

mkdir -p $PREFIX/bin $PREFIX/lib $PREFIX/include

if [ -n "$OSX_ARCH" ] ; then
    sdk=/
    FC=gfortran-4.2
    SOEXT=dylib
    SOFLAGS=(
	-dynamiclib
	-static-libgfortran
	-install_name '@rpath/librpfits.dylib'
	-arch $OSX_ARCH
	-compatibility_version 1.0.0
	-current_version 1.0.0
	-headerpad_max_install_names
	-isysroot $sdk
	-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET
    )
    EXEFLAGS=(
	-dynamic
    )
else
    FC=gfortran
    SOEXT=so.0
    SOFLAGS=(
	-shared
	-fPIC
	-Wl,-soname,librpfits.so.0
    )
    EXEFLAGS=()
fi

$FC "${SOFLAGS[@]}" $FFLAGS \
    -o $PREFIX/lib/librpfits.$SOEXT \
    code/*.f code/utdate.c code/darwin/*.f

for bin in rpfex rpfhdr ; do
    gcc "${EXEFLAGS[@]}" \
	-o $PREFIX/bin/$bin \
	code/$bin.c $PREFIX/lib/librpfits.$SOEXT
done

cp -a code/RPFITS.h code/rpfits.inc $PREFIX/include

if [ -z "$OSX_ARCH" ] ; then
    (cd $PREFIX/lib && ln -s librpfits.$SOEXT librpfits.so)
fi
