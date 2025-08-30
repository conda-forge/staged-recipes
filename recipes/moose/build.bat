@ECHO ON
setlocal enabledelayedexpansion

REM Set environment variables for HDF5 and other dependencies
set "HDF5_DIR=%PREFIX%"
set "GSL_DIR=%PREFIX%"
set "PKG_CONFIG_PATH=%PREFIX%\lib\pkgconfig;%PKG_CONFIG_PATH%"

REM Configure compiler flags to use conda environment
set "CFLAGS=-I%PREFIX%\include %CFLAGS%"
set "CXXFLAGS=-I%PREFIX%\include %CXXFLAGS%"
set "LDFLAGS=-L%PREFIX%\lib %LDFLAGS%"

REM Ensure we're using the right Python
echo Using Python: %PYTHON%
"%PYTHON%" --version

REM Check if pyproject.toml or setup.py exists
if exist pyproject.toml (
    echo Found pyproject.toml, using modern build
    "%PYTHON%" -m pip install . --no-deps -vv --config-settings=setup-args="-Dcpp_std=c++20 -Duse_hdf5=true"
) else if exist setup.py (
    echo Found setup.py, using legacy build
    "%PYTHON%" setup.py build_ext --inplace
    "%PYTHON%" -m pip install . --no-deps -vv
) else (
    echo Trying direct meson build as fallback
    meson setup --wipe _build --prefix=%PREFIX% --buildtype=release --vsenv -Duse_mpi=false -Duse_hdf5=true
    if errorlevel 1 goto error
    
    meson compile -vC _build
    if errorlevel 1 goto error
    
    meson install -C _build
    if errorlevel 1 goto error
)

REM Verify the installation worked
if exist "%SP_DIR%\moose" (
    echo SUCCESS: MOOSE installed to %SP_DIR%\moose
    dir "%SP_DIR%\moose"
) else (
    echo ERROR: MOOSE not found in %SP_DIR%
    echo Contents of SP_DIR:
    dir "%SP_DIR%"
    goto error
)

goto end

:error
echo Build failed with error level %ERRORLEVEL%
exit /B 1

:end
echo Build completed successfully
