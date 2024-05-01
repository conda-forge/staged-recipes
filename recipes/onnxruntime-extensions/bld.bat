@echo off
setlocal

for /f "usebackq tokens=* delims=" %%a in (`%PYTHON% -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))"`) do set "PYTHON3_LIBRARY=%%a"
for /f "usebackq tokens=* delims=" %%a in (`%PYTHON% -c "import sysconfig; print(sysconfig.get_config_var('LDLIBRARY'))"`) do set "PYTHON3_LIBRARY=%PYTHON3_LIBRARY%/%%a"
for /f "usebackq tokens=* delims=" %%a in (`%PYTHON% -c "import sysconfig; print(sysconfig.get_path('include'))"`) do set "PYTHON3_INCLUDE_DIR=%%a"

set "CMAKE_ARGS= -DPython_EXECUTABLE=%PYTHON% -DPYTHON3_EXECUTABLE=%PYTHON% -DPYTHON3_LIBRARY=%PYTHON3_LIBRARY% -DPYTHON3_INCLUDE_DIR=%PYTHON3_INCLUDE_DIR%"

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation

endlocal
