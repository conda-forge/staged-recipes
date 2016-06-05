#!/bin/bash

# Main variables
# --------------
BIN=$PREFIX/lib/qt5/bin
QTCONF=$BIN/qt.conf


# Compile
# -------
chmod +x configure

if [ `uname` == Linux ]; then
    MAKE_JOBS=$CPU_COUNT

    ./configure -prefix $PREFIX \
                -libdir $PREFIX/lib \
                -bindir $PREFIX/lib/qt5/bin \
                -headerdir $PREFIX/include/qt5 \
                -archdatadir $PREFIX/lib/qt5 \
                -datadir $PREFIX/share/qt5 \
                -L $PREFIX/lib \
                -I $PREFIX/include \
                -release \
                -opensource \
                -confirm-license \
                -shared \
                -nomake examples \
                -nomake tests \
                -verbose \
                -skip enginio \
                -skip location \
                -skip sensors \
                -skip serialport \
                -skip script \
                -skip serialbus \
                -skip quickcontrols2 \
                -skip wayland \
                -skip canvas3d \
                -skip 3d \
                -system-libjpeg \
                -system-libpng \
                -system-zlib \
                -qt-pcre \
                -qt-xcb \
                -qt-xkbcommon \
                -xkb-config-root $PREFIX/lib \
                -dbus \
                -c++11 \
                -no-linuxfb \
                -no-libudev

    LD_LIBRARY_PATH=$PREFIX/lib make -j $MAKE_JOBS
    make install
fi

if [ `uname` == Darwin ]; then
    # Let Qt set its own flags and vars
    for x in OSX_ARCH CFLAGS CXXFLAGS LDFLAGS
    do
        unset $x
    done

    MACOSX_DEPLOYMENT_TARGET=10.7
    MAKE_JOBS=$(sysctl -n hw.ncpu)

    ./configure -prefix $PREFIX \
                -libdir $PREFIX/lib \
                -bindir $PREFIX/lib/qt5/bin \
                -headerdir $PREFIX/include/qt5 \
                -archdatadir $PREFIX/lib/qt5 \
                -datadir $PREFIX/share/qt5 \
                -L $PREFIX/lib \
                -I $PREFIX/include \
                -release \
                -opensource \
                -confirm-license \
                -shared \
                -nomake examples \
                -nomake tests \
                -verbose \
                -skip enginio \
                -skip location \
                -skip sensors \
                -skip serialport \
                -skip script \
                -skip serialbus \
                -skip quickcontrols2 \
                -skip wayland \
                -skip canvas3d \
                -skip 3d \
                -system-zlib \
                -qt-pcre \
                -qt-freetype \
                -qt-libjpeg \
                -qt-libpng \
                -c++11 \
                -no-framework \
                -no-dbus \
                -no-mtdev \
                -no-harfbuzz \
                -no-xinput2 \
                -no-xcb-xlib \
                -no-libudev \
                -no-egl \
                -no-openssl

    DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib make -j $MAKE_JOBS
    make install
fi


# Post build setup
# ----------------

# Make symlinks of binaries in $BIN to $PREFIX/bin
for file in $BIN/*
do
    ln -sfv ../lib/qt5/bin/$(basename $file) $PREFIX/bin/$(basename $file)-qt5
done

# Remove static libs
rm -rf $PREFIX/lib/*.a

# Add qt.conf file to the package to make it fully relocatable
cp $RECIPE_DIR/qt.conf $BIN/
