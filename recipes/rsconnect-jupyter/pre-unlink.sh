#!/bin/sh
set -e
{
  "${PREFIX}/bin/jupyter-serverextension" disable --sys-prefix --py rsconnect_jupyter
  "${PREFIX}/bin/jupyter-nbextension" uninstall --sys-prefix --py rsconnect_jupyter
} >>"$PREFIX/.messages.txt" 2>&1