#!/bin/bash

VER=$PKG_VERSION
IFS='.' read -a VER_ARR <<< "$VER"

curl "ftp://ftp.tcl.tk/pub/tcl/tcl${VER_ARR[0]}_${VER_ARR[1]}/tcl${VER}-src.tar.gz" > tcl${VER}-src.tar.gz
curl "ftp://ftp.tcl.tk/pub/tcl/tcl${VER_ARR[0]}_${VER_ARR[1]}/tk${VER}-src.tar.gz" > tk${VER}-src.tar.gz

tar xzf tcl${VER}-src.tar.gz
tar xzf tk${VER}-src.tar.gz

ARCH_FLAG=""
if [ "${ARCH}" == "64" ]
then
    ARCH_FLAG="--enable-64bit"
fi

cd $SRC_DIR/tcl${VER}/unix
./configure \
	--prefix="${PREFIX}" \
	$ARCH_FLAG \

make
make install

cd $SRC_DIR/tk${VER}/unix
./configure \
	--prefix="${PREFIX}" \
	$ARCH_FLAG \
	--with-tcl="${PREFIX}/lib" \
	--enable-aqua=yes \

make
make install

cd $PREFIX
rm -rf man share

# Link binaries to non-versioned names to make them easier to find and use.
ln -s "${PREFIX}/bin/tclsh${VER_ARR[0]}.${VER_ARR[1]}" "${PREFIX}/bin/tclsh"
ln -s "${PREFIX}/bin/wish${VER_ARR[0]}.${VER_ARR[1]}" "${PREFIX}/bin/wish"
