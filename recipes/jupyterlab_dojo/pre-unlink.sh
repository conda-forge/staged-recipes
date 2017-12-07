{
  "${PREFIX}/bin/jupyter-labextension" disable @jupyter_dojo/labextension
  "${PREFIX}/bin/jupyter-labextension" uninstall @jupyter_dojo/labextension
} >>"$PREFIX/.messages.txt" 2>&1