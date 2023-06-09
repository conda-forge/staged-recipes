#!/usr/bin/env csh

# Store existing env vars and set to this conda env
# so other installs don't pollute the environment.

if ( $?NCVIS_RESOURCE_DIR ) then
    setenv _CONDA_SET_NCVIS_RESOURCE_DIR "$NCVIS_RESOURCE_DIR"
endif


setenv NCVIS_RESOURCE_DIR "${CONDA_PREFIX}/share/ncvis"