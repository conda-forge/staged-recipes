#!/usr/bin/env csh

# Restore previous env vars if they were set.
unsetenv CARTOPY_OFFLINE_SHARED
if ( $?_CONDA_SET_CARTOPY_OFFLINE_SHARED ) then
    setenv CARTOPY_OFFLINE_SHARED "$_CONDA_SET_CARTOPY_OFFLINE_SHARED"
    unsetenv _CONDA_SET_CARTOPY_OFFLINE_SHARED
endif
