set -ex

cmake ${CMAKE_ARGS} -B _build -D ENABLE_MEMCHECK=OFF
cmake --build _build
cmake --install _build
