@setlocal EnableDelayedExpansion
@echo on

cmake -B build -S %SRC_DIR% ^
      -G "Ninja" ^
      -D YGGDRASIL_RAPIDJSON_HAS_STDSTRING:BOOL=ON ^
      -D YGGDRASIL_RAPIDJSON_BUILD_TESTS:BOOL=OFF ^
      -D YGGDRASIL_RAPIDJSON_BUILD_EXAMPLES:BOOL=OFF ^
      -D YGGDRASIL_RAPIDJSON_BUILD_DOC:BOOL=OFF ^
      -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
      -D "Python3_EXECUTABLE:FILEPATH=%PYTHON%" ^
      %CMAKE_ARGS% || goto :error
cmake --build build -j%CPU_COUNT% || goto :error
cmake --install build || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1

@endlocal
