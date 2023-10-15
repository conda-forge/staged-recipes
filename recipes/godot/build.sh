#!/usr/bin/env bash
set -eux

python "${RECIPE_DIR}/find_licenses.py" --check

scons \
    -j${CPU_COUNT} \
    platform=linuxbsd \
    target=template_release \
    production=yes \
    lto=full

mkdir -p "${PREFIX}/bin"

cp ./bin/godot.linuxbsd.editor.x86_64 "${PREFIX}/bin/godot"
