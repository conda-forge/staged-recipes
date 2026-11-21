@echo on
setlocal

rem MSVC supplies the Windows SDK and linker; setup.py selects clang-cl.
set "PATH=%BUILD_PREFIX%\Library\bin;%PATH%"
where clang-cl
if errorlevel 1 exit /b 1
clang-cl --version
if errorlevel 1 exit /b 1

set "LIBOMP_PREFIX=%LIBRARY_PREFIX%"
set "INCLUDE=%LIBRARY_INC%;%INCLUDE%"
set "PIP_NO_INDEX=1"
if not exist "%LIBRARY_INC%\omp.h" exit /b 1
if not exist "%LIBRARY_LIB%\libomp.lib" exit /b 1
if not exist "%LIBRARY_BIN%\libomp.dll" exit /b 1

"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1

rem Let the unchanged Python wrapper locate the conda-provided OpenMP DLL.
if not exist "%PREFIX%\etc\conda\activate.d" mkdir "%PREFIX%\etc\conda\activate.d"
if errorlevel 1 exit /b 1
if not exist "%PREFIX%\etc\conda\deactivate.d" mkdir "%PREFIX%\etc\conda\deactivate.d"
if errorlevel 1 exit /b 1
for %%E in (bat ps1 sh) do (
    copy /Y "%RECIPE_DIR%\activate.%%E" "%PREFIX%\etc\conda\activate.d\smoothing_on_sphere.%%E"
    if errorlevel 1 exit /b 1
    copy /Y "%RECIPE_DIR%\deactivate.%%E" "%PREFIX%\etc\conda\deactivate.d\smoothing_on_sphere.%%E"
    if errorlevel 1 exit /b 1
)
