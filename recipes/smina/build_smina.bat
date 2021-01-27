@echo on

SETLOCAL EnableDelayedExpansion

rmdir build /S /Q
mkdir build
cd build

:: Patch version.cpp
echo const char* GIT_REV="%GIT_HASH%";     >  version.cpp
echo const char* GIT_TAG="%PKG_VERSION%";  >> version.cpp
echo const char* GIT_BRANCH="conda-forge"; >> version.cpp

cmake %SRC_DIR% %CMAKE_ARGS% ^
    -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DOPENBABEL_DIR="%LIBRARY_PREFIX%" ^
    -DOPENBABEL3_LIBRARIES="%LIBRARY_PREFIX%/bin/openbabel-3.lib" ^
    || goto :error

cmake --build . || goto :error

copy /q smina.exe %LIBRARY_PREFIX%\bin || goto :error

mkdir %LIBRARY_PREFIX%\share\smina || goto :error
robocopy /S /Q ..\examples %LIBRARY_PREFIX%\share\smina || goto :error


goto :EOF

:error
set errorcode=!errorlevel!
echo Failed with error !errorcode!
exit !errorcode!
