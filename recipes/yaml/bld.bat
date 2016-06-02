mkdir build
cd build

cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release ..
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

:: No tests included in the cmake build.
::
:: ctest
:: if errorlevel 1 exit 1

copy ..\include\yaml.h %LIBRARY_INC%
if errorlevel 1 exit 1

copy yaml.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy yaml.lib %LIBRARY_LIB%
if errorlevel 1 exit 1

copy yaml_static.lib %LIBRARY_LIB%
if errorlevel 1 exit 1
