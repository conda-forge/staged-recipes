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
    export CFLAGS="-march=${MARCH}" CXXFLAGS="-march=${MARCH}"
    export CPPFLAGS="-march=${MARCH}" LDFLAGS="-march=${MARCH}"

    # Build on RPM based distros fails without setting LD_LIBRARY_PATH
    # to the build lib dir
    # See https://bugreports.qt.io/browse/QTBUG-5385
    export LD_LIBRARY_PATH=$SRC_DIR/lib

    # extra flags for Linux
    EXTRA_FLAGS="-webkit -gtkstyle -dbus"
fi

if [ `uname` == Darwin ]; then
    # Leave Qt set its own flags and vars, else compilation errors
    # will occur
    for x in OSX_ARCH CFLAGS CXXFLAGS LDFLAGS
    do
    	unset $x
    done

    chmod +x configure

    # extra flags for osx
    EXTRA_FLAGS="-no-framework -platform macx-g++ -arch `uname -m`"

    CPU_COUNT=$(sysctl -n hw.ncpu)
fi

./configure -prefix $PREFIX/lib/qt4 \
            -libdir $PREFIX/lib \
            -bindir $PREFIX/lib/qt4/bin \
            -headerdir $PREFIX/include/qt4 \
            -datadir $PREFIX/lib/qt4 \
            -L $PREFIX/lib \
            -I $PREFIX/include \
            -release \
            -fast \
            -verbose \
            -no-qt3support \
            -nomake examples \
            -nomake demos \
            -nomake docs \
            -opensource \
            -openssl \
            -system-libpng \
            -system-zlib \
            -system-libtiff \
            -system-libjpeg \
            ${EXTRA_FLAGS}

make -j $CPU_COUNT
make install

# Post build setup
# ----------------
BIN=$PREFIX/lib/qt4/bin

# Remove unneeded files
pushd $PREFIX/lib/qt4
rm -rf phrasebooks translations q3porting.xml
popd

# Make symlinks of binaries in $BIN to $PREFIX/bin
for file in $BIN/*
do
    ln -sfv ../lib/qt4/bin/$(basename $file) $PREFIX/bin/$(basename $file)-qt4
done

# Remove qmake-qt4 symlink and add qmake-qt4 bash script
rm -f $PREFIX/bin/qmake-qt4
cp $RECIPE_DIR/qmake-qt4 $PREFIX/bin/

# Add qt.conf file to the package to make it fully relocatable
cp $RECIPE_DIR/qt.conf $BIN/
