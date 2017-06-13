#!/bin/bash

case "$(uname)" in
    Darwin)
	# Fix rpath so linker finds libs during configure stage,
	# otherwise, configure creates empty-string defines for
	# SIZEOF_OFF_T etc in lynx_cfg.h
	export LDFLAGS="-Wl,-rpath -Wl,$PREFIX/lib"
    ;;
esac

./configure \
    --disable-dependency-tracking \
    --prefix="$PREFIX" \
    --disable-echo \
    --enable-default-colors \
    --with-zlib \
    --with-bzlib \
    --enable-ipv6 \
    --disable-idna \
    --with-ssl="$PREFIX" \
    --with-screen=ncurses \
    || (cat config.log; false)

make -j"$CPU_COUNT"
make install
