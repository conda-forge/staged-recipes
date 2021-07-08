set -exou

mkdir qt-build
pushd qt-build


# yum install libxcb-devel \
# libxkbcommon-devel \
# xcb-util-devel \
# xcb-util-image-devel \
# xcb-util-keysyms-devel \
# xcb-util-renderutil-devel \
# xcb-util-wm-devel \
# mesa-libGL-devel \

#export AR=$(basename ${AR})
#export RANLIB=$(basename ${RANLIB})
#export STRIP=$(basename ${STRIP})
#export OBJDUMP=$(basename ${OBJDUMP})
#export CC=$(basename ${CC})
#export CXX=$(basename ${CXX})

if [[ $(uname) == "Linux" ]]; then
   USED_BUILD_PREFIX=${BUILD_PREFIX:-${PREFIX}}
   echo USED_BUILD_PREFIX=${BUILD_PREFIX}

   ln -s ${GXX} g++ || true
   ln -s ${GCC} gcc || true
   ln -s ${USED_BUILD_PREFIX}/bin/${HOST}-gcc-ar gcc-ar || true

   export LD=${GXX}
   export CC=${GCC}
   export CXX=${GXX}
   export PKG_CONFIG_EXECUTABLE=$(basename $(which pkg-config))
   export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/lib64/pkgconfig/"

   chmod +x g++ gcc gcc-ar
   export PATH=${PWD}:${PATH}

   # Copy XCB headers to PREFIX
   cp -r /usr/include/xcb $PREFIX/include
   NPROC=$(nproc)

  ../configure -prefix ${PREFIX} \
             -libdir ${PREFIX}/lib \
             -bindir ${PREFIX}/bin \
             -headerdir ${PREFIX}/include/qt \
             -archdatadir ${PREFIX} \
             -datadir ${PREFIX} \
             -I ${PREFIX}/include \
             -L ${PREFIX}/lib \
             -L ${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64 \
             QMAKE_LFLAGS+="-Wl,-rpath,$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib -L$PREFIX/lib" \
             -opensource \
             -nomake examples \
             -nomake tests \
             -gstreamer 1.0 \
             -skip qtwebengine \
             -confirm-license \
             -system-libjpeg \
             -system-libpng \
             -system-zlib \
             -xcb \
             -xcb-xlib \
             -bundled-xcb-xinput
fi

if [[ $(uname) == "Darwin" ]]; then
  export AR=$(basename ${AR})
  export RANLIB=$(basename ${RANLIB})
  export STRIP=$(basename ${STRIP})
  export OBJDUMP=$(basename ${OBJDUMP})
  export CC=$(basename ${CC})
  export CXX=$(basename ${CXX})

  # Let Qt set its own flags and vars
  for x in OSX_ARCH CFLAGS CXXFLAGS LDFLAGS
  do
      unset $x
  done

  NPROC=$CPU_COUNT

  PLATFORM=""
  if [[ $(arch) == "arm64" ]]; then
    PLATFORM="-device-option QMAKE_APPLE_DEVICE_ARCHS=arm64"
  fi
 
  # Avoid Xcode
    #cp "${RECIPE_DIR}"/xcrun .
    #cp "${RECIPE_DIR}"/xcodebuild .
    # Some test runs 'clang -v', but I do not want to add it as a requirement just for that.
    #ln -s "${CXX}" ${HOST}-clang || true
    # For ltcg we cannot use libtool (or at least not the macOS 10.9 system one) due to lack of LLVM bitcode support.
    #ln -s "${LIBTOOL}" libtool || true
    # Just in-case our strip is better than the system one.
    #ln -s "${STRIP}" strip || true
    #chmod +x ${HOST}-clang libtool strip
    # Qt passes clang flags to LD (e.g. -stdlib=c++)
    #export LD=${CXX}
    #PATH=${PWD}:${PATH}
 
  ../configure -prefix ${PREFIX} \
             -libdir ${PREFIX}/lib \
             -bindir ${PREFIX}/bin \
             -headerdir ${PREFIX}/include/qt \
             -archdatadir ${PREFIX} \
             -datadir ${PREFIX} \
             $PLATFORM \
             -I ${PREFIX}/include \
             -L ${PREFIX}/lib \
             -R $PREFIX/lib \
             -opensource \
             -nomake examples \
             -nomake tests \
             -skip qtwebengine \
             -confirm-license \
             -system-libjpeg \
             -system-libpng \
             -system-zlib \
             -optimize-size \
             -release \
             -no-framework
             # -sdk macosx10.14

fi

# exit 1
make -j$NPROC
make install


# Remove XCB headers
rm -rf $PREFIX/include/xcb
