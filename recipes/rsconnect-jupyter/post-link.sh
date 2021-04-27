#!/bin/sh
set -e
{
  "${PREFIX}/bin/jupyter-nbextension" install --sys-prefix --py rsconnect_jupyter
  "${PREFIX}/bin/jupyter-nbextension" enable --sys-prefix --py rsconnect_jupyter
  "${PREFIX}/bin/jupyter-serverextension" enable --sys-prefix --py rsconnect_jupyter
} >>"$PREFIX/.messages.txt" 2>&1