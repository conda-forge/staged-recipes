cmake ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      -S . -B build

cmake --build build -j $CPU_COUNT
cmake --build build --target install
