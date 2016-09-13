{
  "${PREFIX}/bin/jupyter-serverextension" disable nbexamples --py --sys-prefix
  "${PREFIX}/bin/jupyter-nbextension" disable nbexamples --py --sys-prefix
  "${PREFIX}/bin/jupyter-nbextension" uninstall nbexamples --py --sys-prefix
} >>"$PREFIX/.messages.txt" 2>&1
