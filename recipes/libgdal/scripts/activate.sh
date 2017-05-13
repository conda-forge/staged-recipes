#!/bin/bash
if [[ -z "$GDAL_DATA" ]]; then
  DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
  export GDAL_DATA="${DIR}/../../../share/gdal"
  export _CONDA_SET_GDAL_DATA=1
fi
