pip check
jupyter server extension list
jupyter server extension list 2>&1 | findstr /r "jupyterlab_h5web.*ok"
jupyter labextension list
jupyter labextension list 2>&1 | findstr "jupyterlab-h5web.*ok.*(python, jupyterlab_h5web)"

