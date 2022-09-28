#!/bin/sh

# Copy the git cloned repository into the PREFIX
mv VersionParsing.jl "${PREFIX}/share/julia/clones"

# Add the package from the clone, copy packages, artifacts, and clones into temp repository
julia build.jl
rm -rf "${PREFIX}/share/julia"

# Copy selected components back to main depot
cp "${PREFIX}/share/julia_build_depot" "${PREFIX}/share/julia"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
