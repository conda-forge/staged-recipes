set -ex

cmake ${CMAKE_ARGS} -B _build -D ENABLE_MEMCHECK=OFF -D FETCHCONTENT_TRY_FIND_PACKAGE_MODE=ALWAYS
cmake --build _build --parallel ${CPU_COUNT}
cmake --install _build
