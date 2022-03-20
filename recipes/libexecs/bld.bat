@echo on
setlocal EnableDelayedExpansion

mkdir build || exit 1
cd build || exit 1


cmake %CMAKE_ARGS% .. || exit 1

cmake  --build . -j %CPU_COUNT% || exit 1
cmake --build . --target install || exit 1
