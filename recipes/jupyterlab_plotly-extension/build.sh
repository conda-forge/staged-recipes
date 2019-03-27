#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Packs and installs the extension, nodejs extension rebuild is done automatically
# on jupyterlab startup, when the new extension is detected or was removed.
"${PREFIX}/bin/jupyter" labextension install packages/plotly-extension --no-build

# Shared file not to be included.
rm "${PREFIX}/share/jupyter/lab/settings/build_config.json"
