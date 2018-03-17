#!/bin/bash
./autogen.sh
./configure \
	--prefix="${PREFIX}" \
	--disable-chfn-chsh  \
	--disable-login      \
	--disable-nologin    \
	--disable-su         \
	--disable-setpriv    \
	--disable-runuser    \
	--disable-pylibmount \
	--disable-static     \
	--without-python     \
	--without-systemd    \
	--without-systemdsystemunitdir
make
make check
make install
