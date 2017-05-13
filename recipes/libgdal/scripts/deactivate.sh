#!/bin/bash
if [[ -n "$_CONDA_SET_GDAL_DATA" ]]; then
  unset GDAL_DATA
  unset _CONDA_SET_GDAL_DATA
fi
