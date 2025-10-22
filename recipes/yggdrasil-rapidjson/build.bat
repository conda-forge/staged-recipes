@setlocal

mkdir conda_build
cd conda_build

cmake %CMAKE_ARGS% ^
      -G "Ninja" ^
      -D RAPIDJSON_HAS_STDSTRING:BOOL=ON ^
      -D RAPIDJSON_BUILD_TESTS:BOOL=OFF ^
      -D RAPIDJSON_BUILD_EXAMPLES:BOOL=OFF ^
      -D RAPIDJSON_BUILD_DOC:BOOL=OFF ^
      -D RAPIDJSON_YGGDRASIL:BOOL=ON ^
      -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
      -D "Python3_EXECUTABLE:FILEPATH=%PYTHON%" ^
      ..
if errorlevel 1 exit 1

cmake --install .
if errorlevel 1 exit 1

@endlocal
