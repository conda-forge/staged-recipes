#!/bin/bash

EUPS_HOME="${PREFIX}/eups"
EUPS_DIR="${EUPS_HOME}"
export EUPS_PATH="${PREFIX}/share/eups"

EUPS_PYTHON=$PYTHON  # use PYTHON in the host env for eups

mkdir -p ${EUPS_HOME}

# Install EUPS
echo -e "\nInstalling EUPS..."
echo "Using python at ${EUPS_PYTHON} to install EUPS"
# echo "Configured EUPS_PKGROOT: ${EUPS_PKGROOT}"

mkdir -p "${EUPS_PATH}"/{site,ups_db}
touch "${EUPS_PATH}/ups_db/.conda_keep"
./configure \
    --prefix="${EUPS_DIR}" \
    --with-eups="${EUPS_PATH}" \
    --with-python="${EUPS_PYTHON}"
make install

# eups installs readonly, need to give permission to the user in order to complete the packaging
chmod -R a+r "${EUPS_DIR}"
chmod -R u+w "${EUPS_DIR}"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
