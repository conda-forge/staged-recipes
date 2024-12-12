#!/usr/bin/env bash
set -e

mkdir -p $PREFIX/examples/cudss
cp -rv examples/* $PREFIX/examples/cudss
cp -rv include $PREFIX
cp -rv lib $PREFIX

if [[ -f "${RECIPE_DIR}/common/detect-glibc" ]] ; then
  source "${RECIPE_DIR}/common/detect-glibc"
fi

SYSTEM_GLIBC_VERSION="$(glibc-detect system)"
RECIPE_GLIBC_VERSION="${c_stdlib_version:=0.0.0}"

for file in "${PREFIX}"/lib/libcudss*.so.*; do
    if [[ -f "$file" && ! -L "$file" ]]; then  # Ensure it's a file
      BINARY_GLIBC_VERSION="$(glibc-detect req $file)"
      echo "binary glibc ${BINARY_GLIBC_VERSION} <= recipe glibc ${RECIPE_GLIBC_VERSION} <= system glibc ${SYSTEM_GLIBC_VERSION} $file"
      BINARY_IS_COMPATIBLE="$(glibc-check compatible $BINARY_GLIBC_VERSION $RECIPE_GLIBC_VERSION)"
      if [[ $BINARY_IS_COMPATIBLE == "false" ]] ; then
        echo "The binary is not compatible with the recipe glibc pinning."
        exit 1
      fi
      echo "The binary is compatible."
    fi
done
