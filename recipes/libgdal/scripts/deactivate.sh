#!/bin/bash
# Restore previous GDAL env vars if they were set

unset GDAL_DATA
if [[ -n "$_CONDA_SET_GDAL_DATA" ]]; then
    export GDAL_DATA=$_CONDA_SET_GDAL_DATA
    unset _CONDA_SET_GDAL_DATA
fi

unset GDAL_DRIVER_PATH
if [[ -n "$_CONDA_SET_GDAL_DRIVER_PATH" ]]; then
    export GDAL_DRIVER_PATH=$_CONDA_SET_GDAL_DRIVER_PATH
    unset _CONDA_SET_GDAL_DRIVER_PATH
fi


#   vsizip does not work without this.
unset CPL_ZIP_ENCODING
