pip check
jupyter server extension list
jupyter server extension list 2>&1 | grep -ie "jupyterlab_h5web.*OK"
jupyter labextension list
jupyter labextension list 2>&1 | grep -ie "jupyterlab-h5web.*OK.*(python, jupyterlab_h5web)"

