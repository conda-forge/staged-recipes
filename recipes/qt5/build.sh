#!/bin/bash

BIN=$PREFIX/lib/qt5/bin
QTCONF=$BIN/qt.conf

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
                -no-libudev \
                -gtkstyle \
                -qt-xcb \
                -qt-pcre \
                -openssl \
                -system-libjpeg \
                -system-libpng \
                -system-zlib \
                -qt-xkbcommon \
                -xkb-config-root $PREFIX/lib \
                -dbus
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
                -skip qtwebengine \
                -openssl \
                -system-libjpeg \
                -system-libpng \
                -system-zlib \
                -qt-pcre \
                -platform macx-g++ \
                -no-c++11 \
                -no-framework \
                -no-dbus \
                -no-mtdev \
                -no-harfbuzz \
                -no-xinput2 \
                -no-xcb-xlib \
                -no-libudev \
                -no-egl
fi

make -j $MAKE_JOBS
make install

for file in $BIN/*
do
    ln -sfv ../lib/qt5/bin/$(basename $file) $PREFIX/bin/$(basename $file)-qt5
done

#removes doc, phrasebooks, and translations
rm -rf $PREFIX/share/qt5

# Remove static libs
rm -rf $PREFIX/lib/*.a

# Add qt.conf file to the package to make it fully relocatable
cat <<EOF >$QTCONF
[Paths]
Prefix = $PREFIX/lib/qt5
Libraries = $PREFIX/lib
Headers = $PREFIX/include/qt5

EOF

