#!/usr/bin/env csh

if ( $?TEMPO2 ) then
  setenv _CONDA_SET_TEMPO2 "$TEMPO2"
endif

setenv TEMPO2 "$CONDA_PREFIX/share/tempo2"
