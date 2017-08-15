#!/bin/bash

# Compile
# -------
chmod +x configure

if [ $(uname) == Linux ]; then

    # Download QtWebkit
    curl "http://linorg.usp.br/Qt/community_releases/5.6/${PKG_VERSION}/qtwebkit-opensource-src-${PKG_VERSION}.tar.xz" > qtwebkit.tar.xz
    unxz qtwebkit.tar.xz
    tar xf qtwebkit.tar
    mv qtwebkit-opensource-src* qtwebkit
    patch -p0 < "${RECIPE_DIR}"/0001-qtwebkit-old-ld-compat.patch
    patch -p0 < "${RECIPE_DIR}"/0002-qtwebkit-ruby-1.8.patch
    patch -p0 < "${RECIPE_DIR}"/0003-qtwebkit-O_CLOEXEC-workaround.patch
    patch -p0 < "${RECIPE_DIR}"/0004-qtwebkit-CentOS5-Fix-fucomip-compat-with-gas-2.17.50.patch
    # From https://bugs.webkit.org/show_bug.cgi?id=70610, http://trac.webkit.org/changeset/172759, https://github.com/WebKit/webkit/commit/4d7f0f
    patch -p0 < "${RECIPE_DIR}"/0005-qtwebkit-fix-TEXTREL-on-x86-changeset_172759.patch
    rm qtwebkit.tar

    MAKE_JOBS=$CPU_COUNT

    ./configure -prefix $PREFIX \
                -libdir $PREFIX/lib \
                -bindir $PREFIX/bin \
                -headerdir $PREFIX/include/qt \
                -archdatadir $PREFIX \
                -datadir $PREFIX \
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
                -skip serialbus \
                -skip quickcontrols2 \
                -skip wayland \
                -skip canvas3d \
                -skip 3d \
                -skip webengine \
                -system-libjpeg \
                -system-libpng \
                -system-zlib \
                -qt-pcre \
                -qt-xcb \
                -qt-xkbcommon \
                -xkb-config-root $PREFIX/lib \
                -dbus \
                -no-linuxfb \
                -no-libudev \
                -no-avx \
                -no-avx2 \
                -D _X_INLINE=inline \
                -D XK_dead_currency=0xfe6f \
                -D XK_ISO_Level5_Lock=0xfe13 \
                -D FC_WEIGHT_EXTRABLACK=215 \
                -D FC_WEIGHT_ULTRABLACK=FC_WEIGHT_EXTRABLACK \
                -D GLX_GLXEXT_PROTOTYPES
# To get a much quicker turnaround you can add this: (remember also to add the backslash after GLX_GLXEXT_PROTOTYPES)
# -skip qtwebsockets -skip qtwebchannel -skip qtwayland -skip qtsvg -skip qtsensors -skip qtcanvas3d -skip qtconnectivity -skip declarative -skip multimedia -skip qttools

# If we must not remove strict_c++ from qtbase/mkspecs/features/qt_common.prf
# (0007-qtbase-CentOS5-Do-not-use-strict_c++.patch) then we need to add these
# defines instead:
# -D __u64="unsigned long long" \
# -D __s64="__signed__ long long" \
# -D __le64="unsigned long long" \
# -D __be64="__signed__ long long"

    LD_LIBRARY_PATH=$PREFIX/lib make -j $MAKE_JOBS || exit 1
    make install
fi

if [ $(uname) == Darwin ]; then
    # Let Qt set its own flags and vars
    for x in OSX_ARCH CFLAGS CXXFLAGS LDFLAGS
    do
        unset $x
    done

    export MACOSX_DEPLOYMENT_TARGET=10.9

    ./configure -prefix $PREFIX \
                -libdir $PREFIX/lib \
                -bindir $PREFIX/bin \
                -headerdir $PREFIX/include/qt \
                -archdatadir $PREFIX \
                -datadir $PREFIX \
                -L $PREFIX/lib \
                -I $PREFIX/include \
                -R $PREFIX/lib \
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
                -skip serialbus \
                -skip quickcontrols2 \
                -skip wayland \
                -skip canvas3d \
                -skip 3d \
                -system-libjpeg \
                -system-libpng \
                -system-zlib \
                -qt-pcre \
                -qt-freetype \
                -c++11 \
                -no-framework \
                -no-dbus \
                -no-mtdev \
                -no-harfbuzz \
                -no-xinput2 \
                -no-xcb-xlib \
                -no-libudev \
                -no-egl \
                -no-openssl \
                -sdk macosx10.9 \
    ####

    make -j $CPU_COUNT || exit 1
    make install
fi


# Post build setup
# ----------------
# Remove static libraries that are not part of the Qt SDK.
pushd "${PREFIX}"/lib > /dev/null
    find . -name "*.a" -and -not -name "libQt*" -exec rm -f {} \;
popd > /dev/null

# Add qt.conf file to the package to make it fully relocatable
cp "${RECIPE_DIR}"/qt.conf "${PREFIX}"/bin/

if [ $(uname) == Darwin ]
then
    BIN=$PREFIX/bin

    for name in Assistant Designer Linguist pixeltool qml
    do
        mv ${BIN}/${name}.app ${BIN}/${name}app
    done

    # We built Qt itself with SDK 10.9, but we shouldn't
    # force users to also build their Qt apps with SDK 10.9
    # https://bugreports.qt.io/browse/QTBUG-41238
    sed -i '' s/macosx10\../macosx/g ${PREFIX}/mkspecs/qdevice.pri

    POST_LINK=$BIN/.qt-post-link.sh
    PRE_UNLINK=$BIN/.qt-pre-unlink.sh
    cp $RECIPE_DIR/osx-post.sh $POST_LINK
    cp $RECIPE_DIR/osx-pre.sh $PRE_UNLINK
    chmod +x $POST_LINK $PRE_UNLINK
fi
