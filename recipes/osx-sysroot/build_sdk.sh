#!/bin/bash

find "${RECIPE_DIR}" -name "activate-sdk.sh" -exec cp {} . \;
find "${RECIPE_DIR}" -name "deactivate-sdk.sh" -exec cp {} . \;

find . -name "activate-sdk.sh" -exec sed -i.bak "s|@MACOSX_SDK_VERSION@|${MACOSX_SDK_VERSION}|g" "{}" \;
find . -name "activate-sdk.sh.bak" -exec rm "{}" \;

mkdir -p "${PREFIX}"/etc/conda/{de,}activate.d/
cp "${SRC_DIR}"/activate-sdk.sh "${PREFIX}"/etc/conda/activate.d/activate_"${PKG_NAME}".sh
cp "${SRC_DIR}"/deactivate-sdk.sh "${PREFIX}"/etc/conda/deactivate.d/deactivate_"${PKG_NAME}".sh
