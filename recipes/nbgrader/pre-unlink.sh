"${PREFIX}/bin/jupyter-nbextension" disable nbgrader --py --sys-prefix >> "${PREFIX}/.messages.txt" 2>&1
"${PREFIX}/bin/jupyter-nbextension" uninstall nbgrader --py --sys-prefix >> "${PREFIX}/.messages.txt" 2>&1
"${PREFIX}/bin/jupyter-serverextension" disable nbgrader --py --sys-prefix >> "${PREFIX}/.messages.txt" 2>&1
