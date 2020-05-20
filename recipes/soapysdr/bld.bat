setlocal EnableDelayedExpansion
@echo on

:: Make a build folder and change to it
mkdir build
cd build

:: configure
:: enable components explicitly so we get build error when unsatisfied
cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DLIB_SUFFIX:STRING="" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DPYTHON_EXECUTABLE=$PYTHON ^
    -DPYTHON_INSTALL_DIR:PATH="%PREFIX%\Lib\site-packages" ^
    -DSOAPY_SDR_EXTVER=%PKG_BUILDNUM% ^
    -DENABLE_APPS=ON ^
    -DENABLE_DOCS=OFF ^
    -DENABLE_LIBRARY=ON ^
    -DENABLE_PYTHON=ON ^
    -DENABLE_TESTS=ON ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1
