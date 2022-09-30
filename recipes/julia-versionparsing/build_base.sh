#!/bin/sh

# Copy the git cloned repository into the PREFIX
mkdir -p "${PREFIX}/share/julia/clones/"
cp -r "${SRC_DIR}/${JULIA_PKG_NAME}.jl" "${PREFIX}/share/julia/clones/"

JULIA_BUILD_DEPOT="${PREFIX}/share/julia_build_depot"
export JULIA_DEPOT_PATH="${JULIA_BUILD_DEPOT}"


# Add the package from the clone, copy packages, artifacts, and clones into temp repository
# DISABLED, reenable for depot install
#julia "${RECIPE_DIR}/build.jl"

if [[ -d "${PREFIX}/share/julia/clones/${JULIA_PKG_NAME}.jl/.git" ]]
then
    # Do not pack hooks
    rm -rf "${PREFIX}/share/julia/clones/${JULIA_PKG_NAME}.jl/.git/hooks"
    # Move .git directory so that it gets packaged
    mv "${PREFIX}/share/julia/clones/${JULIA_PKG_NAME}.jl/.git" "${PREFIX}/share/julia/clones/${JULIA_PKG_NAME}.jl/git" 
else
    echo "${PREFIX}/share/julia/clones/${JULIA_PKG_NAME}.jl is not a git repository"
fi

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/zz_${PKG_NAME}_${CHANGE}.sh"
done

# Populate activate script with name, uuid, and version info
sed -i "3 a \\
name=\"${JULIA_PKG_NAME}\"\\
uuid=\"${JULIA_PKG_UUID}\"\\
version=\"${PKG_VERSION}\"\\
" "${PREFIX}/etc/conda/activate.d/zz_${PKG_NAME}_activate.sh"
