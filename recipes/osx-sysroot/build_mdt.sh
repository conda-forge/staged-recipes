#!/bin/bash

find "${RECIPE_DIR}" -name "activate-mdt.sh" -exec cp {} . \;
find "${RECIPE_DIR}" -name "deactivate-mdt.sh" -exec cp {} . \;

find . -name "activate-mdt.sh" -exec sed -i.bak "s|@MACOSX_DEPLOYMENT_TARGET@|${_MACOSX_DEPLOYMENT_TARGET_}|g" "{}" \;
find . -name "activate-mdt.sh" -exec sed -i.bak "s|@PLATFORM@|${cross_target_platform//-/_}|g" "{}" \;
find . -name "activate-mdt.sh.bak" -exec rm "{}" \;

find . -name "deactivate-mdt.sh" -exec sed -i.bak "s|@PLATFORM@|${cross_target_platform//-/_}|g" "{}" \;
find . -name "deactivate-mdt.sh.bak" -exec rm "{}" \;

mkdir -p "${PREFIX}"/etc/conda/{de,}activate.d/
cp "${SRC_DIR}"/activate-mdt.sh "${PREFIX}"/etc/conda/activate.d/activate_"${PKG_NAME}".sh
cp "${SRC_DIR}"/deactivate-mdt.sh "${PREFIX}"/etc/conda/deactivate.d/deactivate_"${PKG_NAME}".sh
