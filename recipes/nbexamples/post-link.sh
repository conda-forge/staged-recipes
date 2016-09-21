{
  "${PREFIX}/bin/jupyter-nbextension" install nbexamples --py --sys-prefix
  "${PREFIX}/bin/jupyter-nbextension" enable nbexamples --py --sys-prefix
  "${PREFIX}/bin/jupyter-serverextension" enable nbexamples --py --sys-prefix
} >>"$PREFIX/.messages.txt" 2>&1
