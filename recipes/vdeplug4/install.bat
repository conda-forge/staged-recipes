@echo on
setlocal EnableDelayedExpansion

cd build || exit 1

cmake --build . --target install || exit 1
