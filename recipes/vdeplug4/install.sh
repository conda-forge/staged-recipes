#!/bin/bash

set -xe


cd build && cmake --build . --target install
case "$PKG_NAME" in
    vdeplug4)
	rm -rf "$PREFIX"/lib
	rm -rf "$PREFIX"/include
	rm -rf "$PREFIX"/man/man1/libvde*
	rm -rf "$PREFIX"/man/man3/libvde*
	rm -rf "$PREFIX"/share
	;;
    libvdeplug4)
	rm -rf "$PREFIX"/bin
	rm -rf "$PREFIX"/man1/dpipe.1
	rm -rf "$PREFIX"/man1/vde_plug.1
	;;
    *)
	echo "::ERROR:: unknown PKG_NAME: '$PKG_NAME'"
	exit 1
	;;
esac
