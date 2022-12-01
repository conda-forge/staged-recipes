#!/bin/bash
# mkdir build
cd build
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX= ..
make
make DESTDIR="$PREFIX" install
ln -s ../libexec/vncserver "$PREFIX/bin/vncserver"

# https://github.com/TigerVNC/tigervnc/blob/v1.12.0/BUILDING.txt#L100-L146
# mkdir unix
cp -R "$SRC_DIR/unix/xserver" unix/
cd unix/xserver
patch -p1 < "$SRC_DIR/unix/xserver120.patch"
autoreconf -fiv

X_PREFIX=/usr
./configure --with-pic --without-dtrace --disable-static --disable-dri \
      --disable-xinerama --disable-xvfb --disable-xnest --disable-xorg \
      --disable-dmx --disable-xwin --disable-xephyr --disable-kdrive \
      --disable-config-dbus --disable-config-hal --disable-config-udev \
      --disable-dri2 --enable-install-libxf86config --enable-glx \
      --with-default-font-path="catalogue:/etc/X11/fontpath.d,built-ins" \
      --with-fontdir=$X_PREFIX/share/X11/fonts \
      --with-xkb-path=$X_PREFIX/share/X11/xkb \
      --with-xkb-output=/var/lib/xkb \
      --with-xkb-bin-directory=$X_PREFIX/bin \
      --with-serverconfig-path=$X_PREFIX/lib/xorg \
      --with-dri-driver-path=$X_PREFIX/lib/dri \
      --disable-glx

make TIGERVNC_SRCDIR="$SRC_DIR"
