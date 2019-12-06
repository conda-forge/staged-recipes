#!/bin/csh
# Store existing env vars so we can restore them later
if ( $?MAGPLUS_HOME ) then
    setenv _CONDA_SET_MAGPLUS_HOME "$MAGPLUS_HOME"
endif

setenv MAGPLUS_HOME "$CONDA_PREFIX"
