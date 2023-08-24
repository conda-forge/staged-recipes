#!/bin/bash

find "${RECIPE_DIR}" -name "activate-sysroot.sh" -exec cp {} . \;
find "${RECIPE_DIR}" -name "deactivate-sysroot.sh" -exec cp {} . \;

find . -name "activate-sysroot.sh" -exec sed -i.bak "s|@MACOSX_DEPLOYMENT_TARGET@|${_MACOSX_DEPLOYMENT_TARGET_}|g" "{}" \;
find . -name "activate-sysroot.sh" -exec sed -i.bak "s|@PLATFORM@|${cross_target_platform//-/_}|g" "{}" \;
find . -name "activate-sysroot.sh.bak" -exec rm "{}" \;

find . -name "deactivate-sysroot.sh" -exec sed -i.bak "s|@PLATFORM@|${cross_target_platform//-/_}|g" "{}" \;
find . -name "deactivate-sysroot.sh.bak" -exec rm "{}" \;

mkdir -p "${PREFIX}"/etc/conda/{de,}activate.d/
cp "${SRC_DIR}"/activate-sysroot.sh "${PREFIX}"/etc/conda/activate.d/activate_"${PKG_NAME}".sh
cp "${SRC_DIR}"/deactivate-sysroot.sh "${PREFIX}"/etc/conda/deactivate.d/deactivate_"${PKG_NAME}".sh
