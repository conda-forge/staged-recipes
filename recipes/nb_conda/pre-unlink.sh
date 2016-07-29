{
  "${PREFIX}/bin/jupyter-nbextension" disable nb_conda --py --sys-prefix
  "${PREFIX}/bin/jupyter-serverextension" disable nb_conda --py --sys-prefix
} >>"$PREFIX/.messages.txt" 2>&1
