#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

ls -R ${SRC_DIR}
# Packs and installs the extension, nodejs extension rebuild is done automatically
# on jupyterlab startup, when the new extension is detected or was removed.
"${PREFIX}/bin/jupyter" labextension install ${SRC_DIR}/package --no-build

# Shared file not to be included.
rm "${PREFIX}/share/jupyter/lab/settings/build_config.json"
