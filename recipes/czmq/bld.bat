@setlocal
set CONFIGURATION=Release

:: Copy zmq library without version if not already existing
if not exist %LIBRARY_LIB%\libzmq.lib (
    copy /y %LIBRARY_LIB%\libzmq-mt-4*.lib /b %LIBRARY_LIB%\libzmq.lib
)
if errorlevel 1 exit 1
if not exist %LIBRARY_BIN%\libzmq.dll (
    copy /y %LIBRARY_BIN%\libzmq-mt-4*.dll /b %LIBRARY_BIN%\libzmq.dll
)
if errorlevel 1 exit 1
for /r "%LIBRARY_BIN%" %%i in (*.dll) do @echo %%i
for /r "%LIBRARY_LIB%" %%i in (*.lib) do @echo %%i

mkdir build
cd build

:: Using nmake
cmake -G "NMake Makefiles" -D CMAKE_BUILD_TYPE=%CONFIGURATION% -D CMAKE_INCLUDE_PATH="%LIBRARY_INC%" -D CMAKE_LIBRARY_PATH="%LIBRARY_LIB%" -D CMAKE_C_FLAGS_RELEASE="/MT" -D CMAKE_CXX_FLAGS_RELEASE="/MT" -D CMAKE_C_FLAGS_DEBUG="/MTd" CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ..
:: cmake -G "NMake Makefiles" -D CMAKE_BUILD_TYPE=%CONFIGURATION% -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -D CMAKE_LIBRARY_PATH=%LIBRARY_LIB% CMAKE_INCLUDE_PATH=%LIBRARY_INC% ..
if errorlevel 1 exit 1
for /r %%i in (*) do @echo %%i
nmake install
if errorlevel 1 exit 1

:: Using Visual studio
:: cmake -G "%CMAKE_GENERATOR%" -D CMAKE_BUILD_TYPE=%CONFIGURATION% -D CMAKE_INCLUDE_PATH="%LIBRARY_INC%" -D CMAKE_LIBRARY_PATH="%LIBRARY_LIB%" -D CMAKE_C_FLAGS_RELEASE="/MT" -D CMAKE_CXX_FLAGS_RELEASE="/MT" -D CMAKE_C_FLAGS_DEBUG="/MTd" CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ..
:: if errorlevel 1 exit 1
:: msbuild /v:minimal /p:Configuration=%CONFIGURATION% czmq.vcxproj
:: if errorlevel 1 exit 1
:: msbuild /v:minimal /p:Configuration=%CONFIGURATION% czmq_selftest.vcxproj
:: if errorlevel 1 exit 1
:: ctest -C "%Configuration%" -V
:: if errorlevel 1 exit 1

@endlocal