cmake -S . -B build -DDOTNET_DIR=%DOTNET_ROOT% %CMAKE_ARGS% || goto :error
cmake --build build || goto :error
cmake --install build || goto :error

goto :EOF

:error
echo Failed with #%errorlevel%.
exit 1
