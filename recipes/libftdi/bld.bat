mkdir build
cd build
REM Configure step
if "%ARCH%"=="32" (
set MINGW=%MINGW32%
) else (
set MINGW=%MINGW64%
)
set PATH=%MINGW%;%PATH%
cmake -G "MinGW Makefiles" -DCMAKE_INSTALL_PREFIX="%PREFIX%\Library" -DCMAKE_PREFIX_PATH="%PREFIX%\Library" "%SRC_DIR%"
if errorlevel 1 exit 1
REM Build step
cmake --build .
if errorlevel 1 exit 1
REM Install step
cmake --build . --target install
if errorlevel 1 exit 1
