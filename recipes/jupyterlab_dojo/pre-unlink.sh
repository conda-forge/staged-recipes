{
  "${PREFIX}/bin/jupyter-labextension" disable @jupyter_dojo/labextension --sys-prefix
  "${PREFIX}/bin/jupyter-labextension" uninstall @jupyter_dojo/labextension --sys-prefix
} >>"$PREFIX/.messages.txt" 2>&1