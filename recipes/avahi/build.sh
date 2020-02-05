#!/bin/bash

set -ex

# use out-of-tree build
mkdir -pv _build
pushd _build

# we stop here because this is just a placeholder
# to enable future addition of other avahi components
# that may use the top-level build.
# At time of writing we just build the python library
# so we do everything in a separate script.

# configure
#${SRC_DIR}/configure \
#	--disable-autoipd \
#	--disable-dbus \
#	--disable-gdbm \
#	--disable-glib \
#	--disable-gobject \
#	--disable-gtk \
#	--disable-gtk3 \
#	--disable-libdaemon \
#	--disable-manpages \
#	--disable-mono \
#	--disable-python \
#	--disable-qt3 \
#	--disable-qt4 \
#	--prefix=${PREFIX} \
#	--with-xml=none \
#;
