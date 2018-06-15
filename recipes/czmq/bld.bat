@setlocal
set CONFIGURATION=Release
:: set CMAKE_GENERATOR0="%CMAKE_GENERATOR%"
set CMAKE_GENERATOR0="NMake Makefiles"

:: Copy zmq library without version if not already existing
if not exist %LIBRARY_LIB%\libzmq.lib (
    copy /y %LIBRARY_LIB%\libzmq-mt-4*.lib /b %LIBRARY_LIB%\libzmq.lib
)
if errorlevel 1 exit 1
if not exist %LIBRARY_BIN%\libzmq.dll (
    copy /y %LIBRARY_BIN%\libzmq-mt-4*.dll /b %LIBRARY_BIN%\libzmq.dll
)
if errorlevel 1 exit 1
:: for /r "%LIBRARY_BIN%" %%i in (*.dll) do @echo %%i
:: for /r "%LIBRARY_LIB%" %%i in (*.lib) do @echo %%i
:: for /r "%LIBRARY_INC%" %%i in (*.h) do @echo %%i

mkdir build
cd build

:: Call cmake
cmake -G %CMAKE_GENERATOR0% -D CMAKE_BUILD_TYPE=%CONFIGURATION% -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ..
if errorlevel 1 exit 1

:: Using nmake
nmake all VERBOSE=1
nmake install

:: Using Visual studio
:: if exist czmq.vcxproj (
::     msbuild /v:minimal /p:Configuration=%CONFIGURATION% czmq.vcxproj
:: ) else (
::     msbuild /v:minimal /p:Configuration=%CONFIGURATION% czmq.vcproj
:: )
:: if errorlevel 1 exit 1
:: if exist czmq_selftest.vcxproj (
::     msbuild /v:minimal /p:Configuration=%CONFIGURATION% czmq_selftest.vcxproj
:: ) else (
::     msbuild /v:minimal /p:Configuration=%CONFIGURATION% czmq_selftest.vcproj
:: )

:: Run tests
if errorlevel 1 exit 1
ctest -C "%Configuration%" -V
if errorlevel 1 exit 1

@endlocal