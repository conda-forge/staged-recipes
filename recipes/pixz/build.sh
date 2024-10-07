#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} =~ .*osx.* ]]; then
    mkdir pkgconfig
    cp ${PREFIX}/lib/pkgconfig/libarchive.pc pkgconfig
    sed -i 's/Libs.private: /Libs.private: -liconv/g' pkgconfig/libarchive.pc
    sed -i 's/Requires.private: iconv//g' pkgconfig/libarchive.pc
    export PKG_CONFIG_PATH="${SRC_DIR}/pkgconfig:${PREFIX}/lib/pkgconfig"
fi

#autoupdate
autoreconf --force --verbose --install
./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib

make -j${CPU_COUNT}
make install

mkdir -p ${PREFIX}/share/man/man1
install -m 644 src/pixz.1 ${PREFIX}/share/man/man1
