# Copy the activate script to $PREFIX/etc/conda/activate.d.
# This will allow them to be run on environment activation.
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}-activate.sh"
