#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/_install_qemu.sh"

# --- Main ---

install_qemu_arch "ppc64le"
