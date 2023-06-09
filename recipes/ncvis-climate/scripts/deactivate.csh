#!/usr/bin/env csh

# Restore previous env vars if they were set.
unsetenv NCVIS_RESOURCE_DIR
if ( $?_CONDA_SET_NCVIS_RESOURCE_DIR ) then
    setenv NCVIS_RESOURCE_DIR "$_CONDA_SET_NCVIS_RESOURCE_DIR"
    unsetenv _CONDA_SET_NCVIS_RESOURCE_DIR
fi