#!/bin/bash

set -ex

pushd _build
${SRC_DIR}/configure \
	--disable-autoipd \
	--disable-gdbm \
	--disable-glib \
	--disable-gobject \
	--disable-gtk \
	--disable-gtk3 \
	--disable-manpages \
	--disable-mono \
	--disable-qt3 \
	--disable-qt4 \
	--enable-dbus \
	--enable-libdaemon \
	--enable-python \
	--enable-python-dbus \
	--enable-pygobject \
	--prefix=${PREFIX} \
	--with-xml=expat \
;

# build
make -j ${CPU_COUNT} -C avahi-python

# install
make -j ${CPU_COUNT} -C avahi-python install
