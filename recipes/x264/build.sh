#!/bin/bash

mkdir -vp ${PREFIX}/bin;

if [[ $ARCH = 64 ]]; then
    export CFLAGS="-Wall -g -m64 -pipe -O2 -march=x86-64 -fPIC"
else
    export CFLAGS="-Wall -g -m32 -pipe -O2 -march=i386 -fPIC"
fi
export CXXLAGS="${CFLAGS}"
#export CPPFLAGS="-I${PREFIX}/include"
#export LDFLAGS="-L${PREFIX}/lib"

ARCH="$(uname 2>/dev/null)"

LinuxInstallation() {
    # Build dependencies:
    # yasm
    # yasm-devel

    chmod +x configure;

    ./configure \
        --enable-pic \
        --enable-shared \
        --prefix=${PREFIX} || return 1;
    make || return 1;
    make install || return 1;

    return 0;
}

DarwinInstallation() {

    chmod +x configure;

    ./configure \
        --enable-pic \
        --enable-shared \
        --prefix=${PREFIX} || return 1;
    make || return 1;
    make install || return 1;

    return 0;
}

case ${ARCH} in
    'Linux')
        LinuxInstallation || exit 1;
        ;;
    'Darwin')
	DarwinInstallation || exit 1;
	;;
    *)
        echo -e "Unsupported machine type: ${ARCH}";
        exit 1;
        ;;
esac
