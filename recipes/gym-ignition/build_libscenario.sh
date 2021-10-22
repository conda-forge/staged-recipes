test "$CI" = "azure" && section="##[section]" || section=""

echo
echo "${section}===================="
echo "${section}Building libscenario"
echo "${section}===================="
echo

# Print the CI environment
echo "##[group] Environment"
env
echo "##[endgroup]"
echo

# Create a temp build folder
build_folder=$(mktemp -d --suffix _libscenario)

# Configure the CMake project
cmake \
    -S ./scenario/ \
    -B ${build_folder}/ \
    -GNinja \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    -DSCENARIO_USE_IGNITION:BOOL=ON \
    -DSCENARIO_ENABLE_BINDINGS:BOOL=OFF

# Compile the CMake project
cmake --build ${build_folder}/

# Install the CMake project
cmake --install ${build_folder}/

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate" ; do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

echo "${section}Finishing: building libscenario"
