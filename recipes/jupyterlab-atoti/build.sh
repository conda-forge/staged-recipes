#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Add the extension but don't build it.
# The goal is just to let JupyterLab move our package to the folder
# where it keeps the tarballs of installed packages.
# The actual Webpack build will happen in the post-link script.
"${PREFIX}/bin/jupyter" labextension install . --no-build
