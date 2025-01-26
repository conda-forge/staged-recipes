cmake -G "Ninja" -B "build" \
      -D CMAKE_BUILD_TYPE:STRING='Release' \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=${PREFIX} \
      -D QT_HOST_PATH:FILEPATH=${PREFIX}

ninja -C build install