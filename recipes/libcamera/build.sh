#!/bin/bash
set -xeuo pipefail

meson setup build ${MESON_ARGS}
ninja -C build install
