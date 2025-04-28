# build instructions for onsdel-solver

cmake -G Ninja -B build -S . \
      -D CMAKE_BUILD_TYPE:STRING="Release" \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX

ninja -C build install