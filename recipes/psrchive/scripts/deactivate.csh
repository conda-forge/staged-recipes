#!/usr/bin/env csh

unsetenv PSRCHIVE

if ( $?_CONDA_SET_PSRCHIVE ) then
  setenv PSRCHIVE "$_CONDA_SET_PSRCHIVE"
  unsetenv _CONDA_SET_PSRCHIVE
endif
