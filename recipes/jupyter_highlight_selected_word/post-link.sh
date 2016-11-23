#!/bin/bash
# We redirect stderr & stdout to conda's .messages.txt; for details, see
#     http://conda.pydata.org/docs/building/build-scripts.html
{
  "${PREFIX}/bin/python" -c "import logging; from jupyter_contrib_core.notebook_compat.nbextensions import install_nbextension_python; install_nbextension_python('jupyter_highlight_selected_word', sys_prefix=True, logger=logging.getLogger())"
} >>"${PREFIX}/.messages.txt" 2>&1
