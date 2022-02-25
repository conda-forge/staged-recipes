#!/bin/bash

set -xe


case "$PKG_NAME" in
    dtc)
	make install-bin V=1 PREFIX="$PREFIX"
	;;
    pylibfdt) 
	# thanks for keeping the casing consistent guys...
	# this target really does have an undescore
        # it also rebuilds the python extension even though
        # it's already been built, so we need the CFLAGS
        # and CPPFLAGS from build.sh
	make install_pylibfdt V=1 PREFIX="$PREFIX" \
	    CFLAGS="$CFLAGS" \
	    CPPFLAGS="$CPPFLAGS"
	;;
    libfdt)
	make install-lib install-includes V=1 PREFIX="$PREFIX"
	;;
    *)
	echo "::ERROR:: unknown PKG_NAME: '$PKG_NAME'"
	exit 1
	;;
esac
