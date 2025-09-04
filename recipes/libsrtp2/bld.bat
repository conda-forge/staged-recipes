@echo off

mkdir build
cd build

cmake -G Ninja ^
    %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DCMAKE_INSTALL_BINDIR=bin ^
    -DBUILD_SHARED_LIBS=ON ^
    -DLIBSRTP_TEST_APPS=OFF ^
    -DENABLE_WARNINGS_AS_ERRORS=OFF ^
    ..

if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
