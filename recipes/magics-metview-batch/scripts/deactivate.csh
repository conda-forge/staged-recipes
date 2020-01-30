#!/bin/csh
# Restore previous env vars if any
unsetenv MAGPLUS_HOME

if ( $?_CONDA_SET_MAGPLUS_HOME ) then
    setenv MAGPLUS_HOME "$_CONDA_SET_MAGPLUS_HOME"
    unsetenv _CONDA_SET_MAGPLUS_HOME
endif
