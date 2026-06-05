@echo on

:: Set version for setuptools_scm
set SETUPTOOLS_SCM_PRETEND_VERSION="%PKG_VERSION%"

:: CMake extra configuration:
set EXTRA_CMAKE_ARGS=^
 -G Ninja^
 -D AL_DEVELOPMENT_LAYOUT=OFF^
 -D AL_DOWNLOAD_DEPENDENCIES=OFF^
 -D AL_PLUGINS=OFF^
 -D AL_USE_INSTALLED_CORE=OFF^
 -D AL_PYTHON_BINDINGS=OFF^
 -D AL_BACKEND_HDF5=ON^
 -D AL_BACKEND_UDA=ON^
 -D AL_BACKEND_MDSPLUS=OFF

cmake %CMAKE_ARGS% %EXTRA_CMAKE_ARGS% -B build -S "%SRC_DIR%"
if %ERRORLEVEL% neq 0 exit /b 1

:: Build and install
cmake --build build --target install
if %ERRORLEVEL% neq 0 exit /b 1
