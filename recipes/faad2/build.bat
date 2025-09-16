@echo on
@setlocal EnableDelayedExpansion

cmake -S . -B build -GNinja %CMAKE_ARGS% || goto :error
cmake --build build || goto :error
ctest --test-dir build --output-on-failure || goto :error
cmake --install build || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
