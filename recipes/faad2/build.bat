@echo on
@setlocal EnableDelayedExpansion

cmake -S . -B build -GNinja %CMAKE_ARGS% || goto :error
cmake --build build || goto :error
ctest --test-dir build --output-on-failure || goto :error
xcopy build\*.dll %LIBRARY_PREFIX%\bin
xcopy build\*.lib %LIBRARY_PREFIX%\lib
copy build\faad_cli.exe %LIBRARY_PREFIX%\bin

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
