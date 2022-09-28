#!/bin/env julia

name="VersionParsing"
uuid="81def892-9a0e-5fdd-b105-ffc91e053289"

using Pkg, UUIDs

const CONDA_PREFIX = ENV["PREFIX"]
const JULIA_DEPOT = DEPOT_PATH[1]
const BUILD_DEPOT = joinpath(CONDA_PREFIX, "share", "julia_build_depot")

empty!(DEPOT_PATH)
push!(DEPOT_PATH, BUILD_DEPOT)

# A simple adding like this may entail additional network activity
#Pkg.add("${name}")

# Add the local git repository that conda build cloned
uuid = UUID(uuid); nothing # suppress output
spec = PackageSpec(
    name=name,
    uuid=uuid,
    path="$CONDA_PREFIX/share/julia/clones/$name.jl",
)
Pkg.add(spec)


# Select certain folders
mkpath(BUILD_DEPOT)
const directories = ("packages", "artifacts")
for directory in directories
    try
        mv(joinpath(BUILD_DEPOT, directory), joinpath(JULIA_DEPOT, directory))
    catch err
        @warn "Could not move \$directory" err
    end
end

