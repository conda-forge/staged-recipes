@echo on
@setlocal EnableDelayedExpansion

cmake -S . -B build %CMAKE_ARGS%
cmake --build build
ctest --test-dir build --output-on-failure
cmake --install build
