@echo off

:: Setuptools SCM configuration
set SETUPTOOLS_SCM_PRETEND_VERSION="%PKG_VERSION%"

:: CMake extra configuration:
set extra_cmake_args=-G Ninja ^
    -D BUILD_SHARED_LIBS=OFF ^
    -D CMAKE_INSTALL_RPATH_USE_LINK_PATH=FALSE ^
    -D AL_BACKEND_HDF5=OFF ^
    -D AL_BACKEND_MDSPLUS=OFF ^
    -D AL_BACKEND_UDA=OFF ^
    -D AL_BUILD_MDSPLUS_MODELS=OFF ^
    -D AL_PYTHON_BINDINGS=no-build-isolation ^
    -D Python_EXECUTABLE="%PYTHON%" ^
    -D Python3_EXECUTABLE="%PYTHON%" ^
    -D AL_DOWNLOAD_DEPENDENCIES=OFF ^
    -D AL_DEVELOPMENT_LAYOUT=OFF

cmake %CMAKE_ARGS% "%extra_cmake_args%" ^
    -B build -S "%SRC_DIR%"
if errorlevel 1 exit /b 1

:: Build
cmake --build build
if errorlevel 1 exit /b 1

:: Install
%PYTHON% -m pip install imas_core --no-deps --no-build-isolation --find-links build\dist\
if errorlevel 1 exit /b 1

:: Remove unnecessary files
rmdir /s /q "%SP_DIR%\imas_core.libs"
if errorlevel 1 exit /b 1

rmdir /s /q "%SP_DIR%\share\common"
if errorlevel 1 exit /b 1
