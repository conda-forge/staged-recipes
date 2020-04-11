if [[ "$ARCH" == "64" ]]; then
  export PLATFORM=linux-g++-64;
else
  export PLATFORM=linux-g++-32;
fi

if [[ ${HOST} =~ .*linux.* ]]; then
  # Missing g++ workaround.
  ln -s ${GXX} g++ || true
  chmod +x g++
  export PATH=${PWD}:${PATH}
fi

qmake \
     -spec $PLATFORM \
     DISABLE_UPDATE_CHECK=1 \
     DRAW_LIBRARY_PATH=${PREFIX}/share/ldraw; \
     lrelease \
     leocad.pro 

make install
