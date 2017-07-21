# Install BeakerX notebook extension
"${PREFIX}/bin/jupyter-nbextension" install beakerx --py --sys-prefix > /dev/null 2>&1

# Enable BeakerX notebook extension
"${PREFIX}/bin/jupyter-nbextension" enable beakerx --py --sys-prefix > /dev/null 2>&1
