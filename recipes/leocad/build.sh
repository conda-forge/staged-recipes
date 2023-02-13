mkdir build
cd build

if [[ "$ARCH" == "64" ]]; then
  export PLATFORM=linux-g++-64;
else
  export PLATFORM=linux-g++-32;
fi

if [[ ${HOST} =~ .*linux.* ]]; then
  echo "QMAKE_LIBS_OPENGL=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/libGL.so" >> ../leocad.pro
  # Missing g++ workaround.
  ln -s ${GXX} g++ || true
  chmod +x g++
  export PATH=${PWD}:${PATH}
fi

qmake \
  DISABLE_UPDATE_CHECK=1 \
  LDRAW_LIBRARY_PATH=${PREFIX}/share/ldraw \
  CONFIG+=release \
  INSTALL_PREFIX=$PREFIX \
  QMAKE_LFLAGS="${LDFLAGS}" \
  QMAKE_CXXFLAGS="${CXXFLAGS}" \
  ../leocad.pro

make install
