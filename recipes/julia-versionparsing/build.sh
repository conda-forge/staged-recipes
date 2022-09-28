#!/bin/sh

name="VersionParsing"
uuid="81def892-9a0e-5fdd-b105-ffc91e053289"

# Copy the git cloned repository into the PREFIX
mkdir -p "${PREFIX}/share/julia/clones/"
mv "${SRC_DIR}/${name}.jl" "${PREFIX}/share/julia/clones/"

# Add the package from the clone, copy packages, artifacts, and clones into temp repository
julia "${RECIPE_DIR}/build.jl"

rm -rf "${PREFIX}/share/julia"

# Copy selected components back to main depot
mv "${PREFIX}/share/julia_build_depot" "${PREFIX}/share/julia"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
