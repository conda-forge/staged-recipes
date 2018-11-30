#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Packs and installs the extension, nodejs extension rebuild is done automatically
# on jupyterlab startup, when the new extension is detected or was removed.
"${PREFIX}/bin/jupyter" labextension install . --no-build

"${PYTHON}" -m pip install . --no-deps --ignore-installed -vvv

# Shared file not to be included.
rm -f "${PREFIX}/share/jupyter/lab/settings/build_config.json"
