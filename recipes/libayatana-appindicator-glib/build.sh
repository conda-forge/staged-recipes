#!/bin/bash

set -euxo pipefail

# vala 0.56's vapigen rejects the <doc:format/> element that gobject-introspection
# >=1.80 writes into .gir files ("unknown child element `doc:format'"), so strip it
# from the .gir files vapigen reads. The element only records which syntax the doc
# comments use, and is not needed by anything downstream.
strip_doc_format() {
    sed -i '/<doc:format /d' "$@"
}

# gi-docgen resolves GIR dependencies through XDG_DATA_DIRS, which is unset in the
# build sandbox, so it would only look in /usr/share and miss GObject-2.0.gir.
export XDG_DATA_DIRS="${PREFIX}/share:${BUILD_PREFIX}/share:${XDG_DATA_DIRS:-/usr/share}"

# Upstream forces CMAKE_INSTALL_PREFIX to /usr when it is left at the default,
# and GNUInstallDirs would then pick lib64 on Alma/RHEL, so pin both explicitly.
cmake -S . -B build -GNinja \
    ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DENABLE_TESTS=OFF

strip_doc_format "${PREFIX}"/share/gir-1.0/*.gir "${BUILD_PREFIX}"/share/gir-1.0/*.gir

# Build the library, its .gir and its .typelib first, then strip the freshly
# generated .gir as well before the vapi and doc targets consume it.
cmake --build build --target src --verbose
strip_doc_format build/src/AyatanaAppIndicatorGlib-2.0.gir

cmake --build build --verbose
cmake --install build
