#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/_install_qemu.sh"

# --- Main ---

arch=$1
install_qemu_arch ${arch}
