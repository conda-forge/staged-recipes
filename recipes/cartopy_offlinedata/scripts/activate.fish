#!/usr/bin/env fish

if set -q CARTOPY_OFFLINE_SHARED
  set -gx _CONDA_SET_CARTOPY_OFFLINE_SHARED "$CARTOPY_OFFLINE_SHARED"
end

if test -d "$CONDA_PREFIX/share/cartopy"
  set -gx CARTOPY_OFFLINE_SHARED "$CONDA_PREFIX/share/cartopy"
else if test -d "$CONDA_PREFIX/Library/share/cartopy"
  set -gx CARTOPY_OFFLINE_SHARED "$CONDA_PREFIX/Library/share/cartopy"
end
