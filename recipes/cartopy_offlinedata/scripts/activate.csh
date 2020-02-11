#!/usr/bin/env csh

# Store existing env vars and set to this conda env
# so other installs don't pollute the environment.

if ( $?CARTOPY_OFFLINE_SHARED ) then
  setenv _CONDA_SET_CARTOPY_OFFLINE_SHARED "$CARTOPY_OFFLINE_SHARED"
endif

if ( -d "${CONDA_PREFIX}/share/cartopy" ) then
  setenv CARTOPY_OFFLINE_SHARED "${CONDA_PREFIX}/share/cartopy"
else if ( -d "${CONDA_PREFIX}/Library/share/cartopy" ) then
  setenv CARTOPY_OFFLINE_SHARED "${CONDA_PREFIX}/Library/share/cartopy"
endif
