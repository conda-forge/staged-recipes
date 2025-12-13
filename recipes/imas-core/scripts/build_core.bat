@echo off

:: Generate capnp.pc file (See https://github.com/capnproto/capnproto/issues/1356)
cmake -DCAPNP_PREFIX="%LIBRARY_PREFIX%" -P "%SRC_DIR%\capnp_pc_gen.cmake"

:: CMake extra configuration:
set CMAKE_EXTRA_ARGS=-G Ninja ^
    -D BUILD_SHARED_LIBS=ON ^
    -D CMAKE_INSTALL_RPATH_USE_LINK_PATH=FALSE ^
    -D AL_BACKEND_HDF5=ON ^
    -D AL_BACKEND_MDSPLUS=OFF ^
    -D AL_BACKEND_UDA=ON ^
    -D AL_BUILD_MDSPLUS_MODELS=OFF ^
    -D AL_PYTHON_BINDINGS=OFF ^
    -D AL_DOWNLOAD_DEPENDENCIES=OFF ^
    -D AL_DEVELOPMENT_LAYOUT=OFF ^
    -D PThreads4W_DIR="%LIBRARY_PREFIX%"

cmake %CMAKE_ARGS% %CMAKE_EXTRA_ARGS% ^
    -B build -S %SRC_DIR%
if errorlevel 1 exit /b 1

:: Install
cmake --build build --target install
if errorlevel 1 exit /b 1

:: Remove unnecessary files
if exist "%LIBRARY_PREFIX%\share\common\" (
    rmdir /s /q "%LIBRARY_PREFIX%\share\common\"
    if errorlevel 1 exit /b 1
)
if exist "%LIBRARY_PREFIX%\lib\pkgconfig\capnp.pc" (
    del "%LIBRARY_PREFIX%\lib\pkgconfig\capnp.pc"
    if errorlevel 1 exit /b 1
)
