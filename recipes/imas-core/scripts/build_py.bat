@echo on

:: Set version for setuptools_scm
set SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%

:: Build and install
%PYTHON% -m pip install . --no-deps --no-build-isolation -vv^
 --config-settings=-DCMAKE_GENERATOR=Ninja^
 --config-settings=-DAL_DEVELOPMENT_LAYOUT=OFF^
 --config-settings=-DAL_DOWNLOAD_DEPENDENCIES=OFF^
 --config-settings=-DAL_PLUGINS=OFF^
 --config-settings=-DAL_USE_INSTALLED_CORE=ON^
 --config-settings=-DPython_EXECUTABLE="%PYTHON%"^
 --config-settings=-DPython3_EXECUTABLE="%PYTHON%"^
 --config-settings=-DAL_BACKEND_HDF5=OFF^
 --config-settings=-DAL_BACKEND_UDA=OFF^
 --config-settings=-DAL_BACKEND_MDSPLUS=OFF
if %ERRORLEVEL% neq 0 exit /b 1