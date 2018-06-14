@setlocal
set CONFIGURATION=Release

mkdir build
cd build
:: Using nmake
:: cmake -G "NMake Makefiles" -D CMAKE_BUILD_TYPE=%CONFIGURATION% -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -D CMAKE_LIBRARY_PATH=%LIBRARY_LIB% CMAKE_INCLUDE_PATH=%LIBRARY_INC% ..
:: if errorlevel 1 exit 1
:: nmake install
:: if errorlevel 1 exit 1

:: Using Visual studio
cmake -G "%CMAKE_GENERATOR%" -D CMAKE_BUILD_TYPE=%CONFIGURATION% -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -D CMAKE_LIBRARY_PATH=%LIBRARY_LIB% CMAKE_INCLUDE_PATH=%LIBRARY_INC% ..
if errorlevel 1 exit 1
msbuild /v:minimal /p:Configuration=%CONFIGURATION% czmq.vcxproj
if errorlevel 1 exit 1
msbuild /v:minimal /p:Configuration=%CONFIGURATION% czmq_selftest.vcxproj
if errorlevel 1 exit 1
ctest -C "%Configuration%" -V
if errorlevel 1 exit 1

@endlocal