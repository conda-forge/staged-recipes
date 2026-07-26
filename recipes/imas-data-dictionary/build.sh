#!/bin/bash

# Setuptools SCM configuration
export SETUPTOOLS_SCM_PRETEND_VERSION=$PKG_VERSION

# Install the package
$PYTHON -m pip install --no-deps --no-build-isolation -vv .

# Modify activate script to include $PKG_VERSION
sed -i "s/PKG_VERSION/${PKG_VERSION}/g" ${RECIPE_DIR}/scripts/activate.sh
sed -i "s/PKG_VERSION/${PKG_VERSION}/g" ${RECIPE_DIR}/scripts/activate.bat

# Install the conda activation and deactivation scripts
for CHANGE in "activate" "deactivate"; do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.bat" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.bat"
done