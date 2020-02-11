#!/usr/bin/env fish

# Restore previous env vars if they were set.
set -e CARTOPY_OFFLINE_SHARED
if set -q _CONDA_SET_CARTOPY_OFFLINE_SHARED
    set -gx  CARTOPY_OFFLINE_SHARED "$_CONDA_SET_CARTOPY_OFFLINE_SHARED"
    set -e _CONDA_SET_CARTOPY_OFFLINE_SHARED
end
