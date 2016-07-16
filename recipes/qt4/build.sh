#!/bin/bash

# Compile
# -------
if [ `uname` == Linux ]; then
    chmod +x configure

    if [ $ARCH == 64 ]; then
        MARCH=x86-64
    else
        MARCH=i686
    fi

    # Building QtWebKit on CentOS 5 fails without setting these flags
    # explicitly. This is caused by using an old gcc version
    # See https://bugs.webkit.org/show_bug.cgi?id=25836#c5
    CFLAGS="-march=${MARCH}" CXXFLAGS="-march=${MARCH}" \
    CPPFLAGS="-march=${MARCH}" LDFLAGS="-march=${MARCH}" \
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
                -verbose \
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
    LD_LIBRARY_PATH=$SRC_DIR/lib make -j $CPU_COUNT

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
                -verbose \
                -openssl \
                -system-zlib \
                -system-libpng \
                -system-libtiff \
                -system-libjpeg \
                -no-framework \
                -platform macx-g++ \
                -arch `uname -m` 

    make -j $(sysctl -n hw.ncpu)
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
