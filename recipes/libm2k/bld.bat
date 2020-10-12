setlocal EnableDelayedExpansion
@echo on

:: Make a build folder and change to it
mkdir build
cd build

:: configure
cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR:PATH="lib" ^
    -DCMAKE_INSTALL_SBINDIR:PATH="bin" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DENABLE_PYTHON=ON ^
    -DENABLE_CSHARP=OFF ^
    -DENABLE_TOOLS=ON ^
    -DBUILD_EXAMPLES=OFF ^
    -DINSTALL_UDEV_RULES=OFF ^
    -DENABLE_PACKAGING=OFF ^
    -DPython_EXECUTABLE=%PYTHON% ^
    -DENABLE_DOC=OFF ^
    -DENABLE_LOG=OFF ^
    -DENABLE_EXCEPTIONS=OFF ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: move Python package to the right place.
cd %LIBRARY_PREFIX%\Lib\site-packages
move libm2k*.egg-info %SP_DIR%
move libm2k.py %SP_DIR%
move _libm2k.pyd %SP_DIR%
