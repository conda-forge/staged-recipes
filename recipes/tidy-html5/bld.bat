cmake -S . -B build_out -G Ninja %CMAKE_ARGS% || goto :error
cmake --build -j%CPU_COUNT% build_out || goto :error
cmake --install build_out || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
