{
  "${PREFIX}/bin/jupyter-nbextension" disable ipython_unittest --py --sys-prefix
  "${PREFIX}/bin/jupyter-nbextension" uninstall ipython_unittest --py --sys-prefix
} >>"$PREFIX/.messages.txt" 2>&1