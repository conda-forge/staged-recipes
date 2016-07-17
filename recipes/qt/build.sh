#!/bin/bash

# Compile
# -------
chmod +x configure

if [ `uname` == Linux ]; then
    ./configure -prefix $PREFIX \
                -libdir $PREFIX/lib \
                -bindir $PREFIX/bin \
                -headerdir $PREFIX/include/qt \
                -datadir $PREFIX \
                -L $PREFIX/lib \
                -I $PREFIX/include \
                -release \
                -fast \
                -no-qt3support \
                -nomake examples \
                -nomake demos \
                -nomake docs \
                -opensource \
                -openssl \
                -webkit \
                -system-zlib \
                -system-libpng \
                -system-libtiff \
                -system-libjpeg \
                -gtkstyle \
                -dbus

    # Build on RPM based distros fails without setting LD_LIBRARY_PATH
    # to the build lib dir
    # See https://bugreports.qt.io/browse/QTBUG-5385
    LD_LIBRARY_PATH=$SRC_DIR/lib make
    make install
fi

if [ `uname` == Darwin ]; then
    # Leave Qt set its own flags and vars, else compilation errors
    # will occur
    for x in OSX_ARCH CFLAGS CXXFLAGS LDFLAGS
    do
        unset $x
    done

    chmod +x configure
    ./configure -prefix $PREFIX \
                -libdir $PREFIX/lib \
                -bindir $PREFIX/bin \
                -headerdir $PREFIX/include/qt \
                -datadir $PREFIX \
                -L $PREFIX/lib \
                -I $PREFIX/include \
                -release \
                -fast \
                -no-qt3support \
                -nomake examples \
                -nomake demos \
                -nomake docs \
                -opensource \
                -openssl \
                -system-zlib \
                -system-libpng \
                -system-libtiff \
                -system-libjpeg \
                -no-framework \
                -arch `uname -m`
                #-platform macx-g++

    make
    make install
fi


# Post build setup
# ----------------

# Remove unneeded files
pushd $PREFIX
rm -rf phrasebooks translations q3porting.xml tests
popd

# Add qt.conf file to the package to make it fully relocatable
cp $RECIPE_DIR/qt.conf $PREFIX/bin/
