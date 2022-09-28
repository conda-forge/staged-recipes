#!/bin/env julia
using Pkg

const CONDA_PREFIX = ENV["PREFIX"]
const JULIA_DEPOT = DEPOT_PATH[1]
const BUILD_DEPOT = joinpath(CONDA_PREFIX, "share", "julia_build_depot")

# A simple adding like this may entail additional network activity
#Pkg.add("VersionParsing")

# Add the local git repository that conda build cloned
Pkg.add(joinpath(CONDA_PREFIX, "share", "julia", "clones", "VersionParsing.jl"))

# Select certain folders
mkpath(BUILD_DEPOT)
const directories = ("packages", "artifacts", "clones")
for directory in directories
    mv(joinpath(JULIA_DEPOT, directory), joinpath(BUILD_DEPOT, directory))
end

