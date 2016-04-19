mkdir build
if errorlevel 1 exit 1

cd build
if errorlevel 1 exit 1


for %%X in (
    "on"
    "off"
  ) do (
    cmake -G ^
               "NMake Makefiles" ^
               -DCMAKE_BUILD_TYPE=Release ^
               -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
               -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
               -DBUILD_SHARED_LIBS=%%X ^
               ..
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

:: No tests included in the cmake build.
::
:: ctest
:: if errorlevel 1 exit 1
)

copy ..\include\yaml.h %LIBRARY_INC%
if errorlevel 1 exit 1

copy yaml.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy yaml.lib %LIBRARY_LIB%
if errorlevel 1 exit 1
