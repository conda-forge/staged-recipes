#!/bin/bash

mkdir -vp ${PREFIX}/bin;

ARCH="$(uname 2>/dev/null)"

export CFLAGS="-m64 -pipe -O2 -march=x86-64 -fPIC"
export CXXFLAGS="${CFLAGS}"
#export CPPFLAGS="-I${PREFIX}/include"
#export LDFLAGS="-L${PREFIX}/lib"

LinuxInstallation() {

    chmod +x configure;

    ./configure \
        --disable-static \
        --enable-linux-lfs \
        --with-ssl \
        --with-zlib \
        --prefix=${PREFIX} || return 1;
    make || return 1;
    make install || return 1;

    rm -rf ${PREFIX}/share/hdf4_examples;

    return 0;
}

OSXInstallation() {

    chmod +x configure;

    ./configure \
        --disable-static \
        --enable-linux-lfs \
        --with-ssl \
        --disable-fortran \
        --with-zlib \
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
        OSXInstallation || exit 1;
        ;;
    *)
        echo -e "Unsupported machine type: ${ARCH}";
        exit 1;
        ;;
esac

#POST_LINK="${PREFIX}/bin/.hdf4-post-link.sh"
#cp -v ${RECIPE_DIR}/post-link.sh ${POST_LINK};
#chmod -v 0755 ${POST_LINK};
