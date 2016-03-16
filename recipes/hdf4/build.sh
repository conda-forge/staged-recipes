#!/bin/bash

ARCH="$(uname 2>/dev/null)"

export CFLAGS="${CFLAGS} -pipe -O2 -fPIC -I${PREFIX}/include"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"

LinuxInstallation() {

    chmod +x configure;

    ./configure \
        --disable-static \
        --enable-linux-lfs \
        --with-ssl \
        --with-zlib \
        --disable-netcdf \
        --disable-fortran \
        --prefix=${PREFIX} || return 1;
    make || return 1;
    make install || return 1;

    rm -rf ${PREFIX}/share/hdf4_examples;

    return 0;
}

MacOSXInstallation() {
	
	export CC=clang
	export CXX=clang++
	
    chmod +x configure;

    ./configure \
        --disable-static \
        --with-ssl \
        --with-zlib \
        --with-jpeg \
        --disable-netcdf \
        --disable-fortran \
        --prefix=${PREFIX} || return 1;
    make || return 1;
    make install || return 1;

    rm -rf ${PREFIX}/share/hdf4_examples;

    return 0;
}

case ${ARCH} in
    'Linux')
        LinuxInstallation || exit 1;
        ;;
    'Darwin')
        MacOSXInstallation || exit 1;
        ;;
    *)
        echo -e "Unsupported machine type: ${ARCH}";
        exit 1;
        ;;
esac

