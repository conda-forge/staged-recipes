# Install BeakerX notebook extension
"${PREFIX}/bin/jupyter-nbextension" install beakerx --py --sys-prefix > /dev/null 2>&1

# Enable BeakerX notebook extension
"${PREFIX}/bin/jupyter-nbextension" enable beakerx --py --sys-prefix > /dev/null 2>&1

# Copy custom CSS and assets to notebook custom directory
# cp -r ./beakerx/custom "${PREFIX}/lib/python3.5/site-packages/notebook/static/custom/" > /dev/null 2>&1
