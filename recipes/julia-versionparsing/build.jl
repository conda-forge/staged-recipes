#!/bin/env julia
#
# This Julia script
# 1. Created a julia_build_depot as the sole depot
# 2. Adds or develops the Julia package installing the the package into julia_build_depot
# 3. The packages and artifacts directories are then extracted for install if they exist.
# 4. Finally, the build depot is removed.
#
# This will install the Julia package and artifact caches so they can be easily
# installed

using Pkg, UUIDs

const CONDA_PREFIX = ENV["PREFIX"]
# JULIA_PKG_{NAME,UUID} are set by build_base.sh
const JULIA_PKG_NAME=ENV["JULIA_PKG_NAME"]
const JULIA_PKG_UUID=ENV["JULIA_PKG_UUID"]
const PKG_VERSION=ENV["PKG_VERSION"]
const JULIA_DEPOT = joinpath(CONDA_PREFIX, "share", "julia")
# This is a temporary depot from which will extract certain directories
const BUILD_DEPOT = joinpath(CONDA_PREFIX, "share", "julia_build_depot")

@info "Environment settings" CONDA_PREFIX, JULIA_DEPOT, BUILD_DEPOT

# Set BUILD_DEPOT as the sole depot
empty!(DEPOT_PATH)
push!(DEPOT_PATH, BUILD_DEPOT)

# A simple adding like this may entail additional network activity
#Pkg.add(JULIA_PKG_NAME)

const uuid = UUID(JULIA_PKG_UUID)
const path = joinpath(JULIA_DEPOT, "clones", "$JULIA_PKG_NAME.jl")
if isdir(joinpath(path, ".git"))
    # Add the local git repository that conda build cloned
    spec = PackageSpec(
        name=JULIA_PKG_NAME,
        uuid=uuid,
        path=path,
        rev="v$PKG_VERSION"
    )
    Pkg.add(spec)
elseif isdir(path)
    # "Develop" the package without a git repository
    # Package cache for this package is likely not created
    spec = PackageSpec(
        name=JULIA_PKG_NAME,
        uuid=uuid,
        path=path,
    )
    Pkg.develop(spec)
end

# Select certain folders
const directories = ("packages", "artifacts")
for directory in directories
    build_dir = joinpath(BUILD_DEPOT, directory)
    target_dir = joinpath(JULIA_DEPOT, directory)
    if isdir(build_dir)
        mv(build_dir, target_dir)
    else
        @warn "$bulid_dir does not exist"
    end
end

# Remove the temporary build depot
rm(BUILD_DEPOT, recursive=true)
