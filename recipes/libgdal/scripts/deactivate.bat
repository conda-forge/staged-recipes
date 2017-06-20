@REM Restore previous GDAL env vars if they were set

@set "GDAL_DATA="
@if defined _CONDA_SET_GDAL_DATA (
  set "GDAL_DATA=%_CONDA_SET_GDAL_DATA%"
  set "_CONDA_SET_GDAL_DATA="
)

@set "GDAL_DRIVER_PATH="
@if defined _CONDA_SET_GDAL_DRIVER_PATH (
  set "GDAL_DRIVER_PATH=%_CONDA_SET_GDAL_DRIVER_PATH%"
  set "_CONDA_SET_GDAL_DRIVER_PATH="
)
