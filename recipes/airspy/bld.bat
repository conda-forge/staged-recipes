setlocal EnableDelayedExpansion
@echo on

:: Make a build folder and change to it
mkdir forgebuild
if errorlevel 1 exit 1
cd forgebuild
if errorlevel 1 exit 1

cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DLIB_SUFFIX="" ^
    -DLIBUSB_INCLUDE_DIR="%LIBRARY_INC%\libusb-1.0" ^
    -DLIBUSB_LIBRARIES="%LIBRARY_LIB%\libusb-1.0.lib" ^
    -DTHREADS_PTHREADS_INCLUDE_DIR="%LIBRARY_INC%" ^
    -DTHREADS_PTHREADS_WIN32_LIBRARY="%LIBRARY_LIB%\pthread.lib" ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1
