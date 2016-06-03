"${PYTHON}" setup.py install --single-version-externally-managed --record=record.txt
"${PREFIX}/bin/jupyter-nbextension" install nb_conda --py --sys-prefix --overwrite
