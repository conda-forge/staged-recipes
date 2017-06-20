@REM Store existing GDAL env vars and set to this conda env
@REM so other GDAL installs don't pollute the environment

@if defined GDAL_DATA (
    set "_CONDA_SET_GDAL_DATA=%GDAL_DATA%"
)
@set "GDAL_DATA=%CONDA_PREFIX%\Library\share\gdal"

@if defined GDAL_DRIVER_PATH (
    set "_CONDA_SET_GDAL_DRIVER_PATH=%GDAL_DRIVER_PATH%"
)

@REM Support plugins if the plugin directory exists
@REM i.e if it has been manually created by the user
@set "GDAL_DRIVER_PATH=%CONDA_PREFIX%\Library\lib\gdalplugins"
@if not exist %GDAL_DRIVER_PATH% (
     set "GDAL_DRIVER_PATH="
)
