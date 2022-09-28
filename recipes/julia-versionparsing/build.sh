#!/bin/sh

name="VersionParsing"
uuid="81def892-9a0e-5fdd-b105-ffc91e053289"

# Copy the git cloned repository into the PREFIX
mkdir -p "${PREFIX}/share/julia/clones/"
mv "${SRC_DIR}/${name}.jl" "${PREFIX}/share/julia/clones/"

# Add the package from the clone, copy packages, artifacts, and clones into temp repository
julia <<JULIA_PACKAGE_BUILD_SCRIPT
using Pkg, UUIDs

const CONDA_PREFIX = ENV["PREFIX"]
const JULIA_DEPOT = DEPOT_PATH[1]
const BUILD_DEPOT = joinpath(CONDA_PREFIX, "share", "julia_build_depot")

# A simple adding like this may entail additional network activity
#Pkg.add("${name}")

# Add the local git repository that conda build cloned
uuid = UUID("${uuid}"); nothing # suppress output
spec = PackageSpec(
    name="${name}",
    uuid=uuid,
    path="${PREFIX}/share/julia/clones/${name}.jl",
)
Pkg.add(spec)


# Select certain folders
mkpath(BUILD_DEPOT)
const directories = ("packages", "artifacts", "clones")
for directory in directories
    try
        mv(joinpath(JULIA_DEPOT, directory), joinpath(BUILD_DEPOT, directory))
    catch err
        @warn "Could not move \$directory" err
    end
end
JULIA_PACKAGE_BUILD_SCRIPT

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
