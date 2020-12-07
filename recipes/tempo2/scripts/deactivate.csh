#!/usr/bin/env csh

unsetenv TEMPO2

if ( $?_CONDA_SET_TEMPO2 ) then
  setenv TEMPO2 "$_CONDA_SET_TEMPO2"
  unsetenv _CONDA_SET_TEMPO2
endif
