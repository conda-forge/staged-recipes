#!/bin/sh

name="VersionParsing"
uuid="81def892-9a0e-5fdd-b105-ffc91e053289"

# Copy the git cloned repository into the PREFIX
mkdir -p "${PREFIX}/share/julia/clones/"
cp -r "${SRC_DIR}/${name}.jl" "${PREFIX}/share/julia/clones/"

JULIA_BUILD_DEPOT="${PREFIX}/share/julia_build_depot"
export JULIA_DEPOT_PATH="${JULIA_BUILD_DEPOT}"


# Add the package from the clone, copy packages, artifacts, and clones into temp repository
julia "${RECIPE_DIR}/build.jl"

# Move .git directory so that it gets packaged
mv "${PREFIX}/share/julia/clones/${name}.jl/.git" "${PREFIX}/share/julia/clones/${name}.jl/git" 

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/zz_${PKG_NAME}_${CHANGE}.sh"
done
