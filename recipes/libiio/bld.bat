setlocal EnableDelayedExpansion
@echo on

:: copy the wingetopt readme (containing licenses) to the source root
copy "deps\wingetopt\README.md" "LICENSE_WINGETOPT.txt"

:: Make a build folder and change to it
mkdir build
cd build

:: configure
:: enable components explicitly so we get build error when unsatisfied
::   WITH_LOCAL_CONFIG requires libini
::   WITH_SERIAL_BACKEND requires libserialport
cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR:PATH="lib" ^
    -DCMAKE_INSTALL_SBINDIR:PATH="bin" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCSHARP_BINDINGS=OFF ^
    -DENABLE_PACKAGING=OFF ^
    -DPYTHON_BINDINGS=ON ^
    -DWITH_DOC=OFF ^
    -DWITH_EXAMPLES=OFF ^
    -DWITH_MAN=OFF ^
    -DWITH_NETWORK_BACKEND=ON ^
    -DWITH_SERIAL_BACKEND=OFF ^
    -DWITH_TESTS=ON ^
    -DWITH_USB_BACKEND=ON ^
    -DWITH_XML_BACKEND=ON ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1
