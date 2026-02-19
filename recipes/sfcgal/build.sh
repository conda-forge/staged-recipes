#/usr/bin/env bash
set -e

if [ $(uname) == Linux ]; then
  export LDFLAGS="$LDFLAGS -L$(PREFIX)/lib64 -L$(PREFIX)/lib -lpthread -lm -lstdc++"
  PLATFORM_OPTS=""
fi

cmake -S . -B build \
         ${CMAKE_ARGS} \
         -G Ninja \
         -D CMAKE_BUILD_TYPE=Release \
         -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
         -D CMAKE_PREFIX_PATH="${PREFIX}" \
         -D SFCGAL_BUILD_TESTS=OFF \
         -Wno-dev

cmake --build build --config Release -j${CPU_COUNT}
cmake --install build
