setlocal EnableDelayedExpansion
@echo on

:: Make a build folder and change to it
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

:: configure
:: change -DLIB_INSTALL_DIR:PATH="lib" to -DCMAKE_INSTALL_LIBDIR:PATH="lib" after 0.6
cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DLIB_INSTALL_DIR:PATH="lib" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DLIBUSB_INCLUDE_DIR:PATH="%LIBRARY_INC%\libusb-1.0" ^
    -DTHREADS_PTHREADS_WIN32_LIBRARY:FILEPATH="%LIBRARY_LIB%\pthread.lib" ^
    -DDETACH_KERNEL_DRIVER=OFF ^
    -DENABLE_ZEROCOPY=OFF ^
    -DINSTALL_UDEV_RULES=OFF ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1
