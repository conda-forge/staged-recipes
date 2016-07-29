{
  "${PREFIX}/bin/jupyter-nbextension" enable nb_conda --py --sys-prefix
  "${PREFIX}/bin/jupyter-serverextension" enable nb_conda --py --sys-prefix
} >>"$PREFIX/.messages.txt" 2>&1
