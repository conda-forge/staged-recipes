setlocal EnableDelayedExpansion
@echo on

:: Make a build folder and change to it
mkdir forgebuild
if errorlevel 1 exit 1
cd forgebuild
if errorlevel 1 exit 1

:: enable gnuradio components explicitly so we get build error when unsatisfied
cmake -G "Ninja" ^
    -DBUILD_SHARED_LIBS=ON ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DLIME_SUITE_EXTVER="condaforge" ^
    -DENABLE_API_DOXYGEN=OFF ^
    -DENABLE_BACKEND_CYAPI=OFF ^
    -DENABLE_BACKEND_LIBUSB=ON ^
    -DENABLE_DESKTOP=OFF ^
    -DENABLE_EVB7COM=OFF ^
    -DENABLE_EXAMPLES=OFF ^
    -DENABLE_FTDI=ON ^
    -DENABLE_FX3=ON ^
    -DENABLE_GUI=ON ^
    -DENABLE_HEADERS=ON ^
    -DENABLE_LIBRARY=ON ^
    -DENABLE_LIMERFE=ON ^
    -DENABLE_LIME_UTIL=ON ^
    -DENABLE_MCU_TESTBENCH=OFF ^
    -DENABLE_OCTAVE=OFF ^
    -DENABLE_PCIE_XILLYBUS=ON ^
    -DENABLE_QUICKTEST=OFF ^
    -DENABLE_REMOTE=OFF ^
    -DENABLE_SIMD_FLAGS="none" ^
    -DENABLE_SOAPY_LMS7=ON ^
    -DENABLE_SPI=OFF ^
    -DENABLE_STREAM_UNITE=OFF ^
    -DENABLE_UTILITIES=OFF ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1
