@setlocal

mkdir conda_build
cd conda_build

cmake %CMAKE_ARGS% ^
      -G "Ninja" ^
      -D YGGDRASIL_RAPIDJSON_HAS_STDSTRING:BOOL=ON ^
      -D YGGDRASIL_RAPIDJSON_BUILD_TESTS:BOOL=OFF ^
      -D YGGDRASIL_RAPIDJSON_BUILD_EXAMPLES:BOOL=OFF ^
      -D YGGDRASIL_RAPIDJSON_BUILD_DOC:BOOL=OFF ^
      -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
      -D "Python3_EXECUTABLE:FILEPATH=%PYTHON%" ^
      ..
if errorlevel 1 exit 1

cmake --install .
if errorlevel 1 exit 1

@endlocal
