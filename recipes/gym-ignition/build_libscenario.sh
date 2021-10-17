cmake \
    -S ./scenario/ \
    -B build/ \
    -GNinja \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    -DSCENARIO_USE_IGNITION:BOOL=ON \
    -DSCENARIO_ENABLE_BINDINGS:BOOL=OFF
cmake --build build/
cmake --install build

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate" ; do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
