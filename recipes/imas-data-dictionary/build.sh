#!/bin/bash

# Setuptools SCM configuration
export SETUPTOOLS_SCM_PRETEND_VERSION=$PKG_VERSION

# Install the package
$PYTHON -m pip install --no-deps --no-build-isolation -vv .

# Modify activate.sh to include $PKG_VERSION
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i "" "s/PKG_VERSION/${PKG_VERSION}/g" ${RECIPE_DIR}/scripts/activate.sh
else
    sed -i "s/PKG_VERSION/${PKG_VERSION}/g" ${RECIPE_DIR}/scripts/activate.sh
fi

# Install the conda activation and deactivation scripts
for CHANGE in "activate" "deactivate"; do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done