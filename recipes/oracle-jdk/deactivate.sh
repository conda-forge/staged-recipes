
# PKG_UUID="${PKG_NAME}-${PKG_VERSION}_${PKG_BUILDNUM}"
DEACTIVATE_SCRIPT="${CONDA_PREFIX}/conda-activate-meta/${PKG_UUID}/deactivate-aux.sh"

if [ -f "${DEACTIVATE_SCRIPT}" ]; then
  source "${DEACTIVATE_SCRIPT}"
  rm "${DEACTIVATE_SCRIPT}"
fi
