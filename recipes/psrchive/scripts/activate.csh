#!/usr/bin/env csh

if ( $?PSRCHIVE ) then
  setenv _CONDA_SET_PSRCHIVE "$PSRCHIVE"
endif

setenv PSRCHIVE "$CONDA_PREFIX"
