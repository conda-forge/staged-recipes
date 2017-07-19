# Uninstall BeakerX notebook extension
"${PREFIX}/bin/jupyter-nbextension" uninstall beakerx --py --sys-prefix > /dev/null 2>&1

# Uninstall BeakerX kernel specs
"${PREFIX}/bin/jupyter-kernelspec" remove clojure cpp groovy java scala sql --sys-prefix

# Copy custom CSS and assets to notebook custom directory
# cp -r ./beakerx/custom "${PREFIX}/lib/python3.5/site-packages/notebook/static/custom/" > /dev/null 2>&1
