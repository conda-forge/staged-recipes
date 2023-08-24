#!/bin/bash

find "${RECIPE_DIR}" -name "activate-sysroot.sh" -exec cp {} . \;
find . -name "activate-sysroot.sh" -exec sed -i.bak "s|@MACOSX_DEPLOYMENT_TARGET@|${MACOSX_DEPLOYMENT_TARGET}|g" "{}" \;
find . -name "activate-sysroot.sh.bak" -exec rm "{}" \;

mkdir -p "${PREFIX}"/etc/conda/{de,}activate.d/
cp "${SRC_DIR}"/activate-sdk.sh "${PREFIX}"/etc/conda/activate.d/activate_"${PKG_NAME}".sh
cp "${SRC_DIR}"/deactivate-sdk.sh "${PREFIX}"/etc/conda/deactivate.d/deactivate_"${PKG_NAME}".sh
