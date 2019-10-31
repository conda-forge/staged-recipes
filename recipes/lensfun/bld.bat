mkdir build && cd build

set CMAKE_CONFIG="Release"
set LD_LIBRARY_PATH=%LIBRARY_LIB%
set INCLUDE=%LIBRARY_INC%

cmake -G "NMake Makefiles" ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_LIBRARY_PATH=%LIBRARY_LIB% ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D ENDIAN_INCLUDE_DIR=%LIBRARY_INC%\endian.h ^
      -D REGEX_INCLUDE_DIR=%LIBRARY_INC%\regex\regex.h ^
      ..
if errorlevel 1 exit 1

cmake --build .
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1
