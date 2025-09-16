@echo on
@setlocal EnableDelayedExpansion

cmake -S . -B build -GNinja -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=1 %CMAKE_ARGS% || goto :error
cmake --build build || goto :error
ctest --test-dir build --output-on-failure || goto :error
xcopy build\*.dll %LIBRARY_PREFIX%\bin || goto :error
xcopy build\*.lib %LIBRARY_PREFIX%\lib || goto :error
copy build\faad_cli.exe %LIBRARY_PREFIX%\bin || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
