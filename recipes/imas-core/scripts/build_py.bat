@echo on

:: Set version for setuptools_scm
set SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%

:: Set CMake args
set CMAKE_ARGS=%CMAKE_ARGS% ^
 -G Ninja^
 -D AL_DEVELOPMENT_LAYOUT=OFF^
 -D AL_DOWNLOAD_DEPENDENCIES=OFF^
 -D AL_PLUGINS=OFF^
 -D AL_USE_INSTALLED_CORE=ON^
 -D AL_PYTHON_BINDINGS=ON^
 -D AL_BACKEND_HDF5=OFF^
 -D AL_BACKEND_UDA=OFF^
 -D AL_BACKEND_MDSPLUS=OFF

:: Build and install
%PYTHON% -m pip install . --no-deps --no-build-isolation -vv
if %ERRORLEVEL% neq 0 exit /b 1