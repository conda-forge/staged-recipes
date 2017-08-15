# Uninstall BeakerX notebook extension
"${PREFIX}/bin/jupyter-nbextension" uninstall beakerx --py --sys-prefix > /dev/null 2>&1

# Uninstall BeakerX kernel specs
# python setup.py kernels --disable > /dev/null 2>&1
"${PREFIX}/bin/jupyter-kernelspec" remove clojure cpp groovy java scala sql > /dev/null 2>&1

# Update kernelspec_class in jupyter_notebook_config.json
# python setup.py kernelspec_class --disable > /dev/null 2>&1

# Restore original custom CSS and assets to notebook custom directory
# cp -r ./beakerx/custom "${PREFIX}/lib/python3.5/site-packages/notebook/static/custom/" > /dev/null 2>&1
