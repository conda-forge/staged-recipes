#!/bin/env julia

using Pkg, UUIDs

const CONDA_PREFIX = ENV["PREFIX"]
const JULIA_PKG_NAME=ENV["JULIA_PKG_NAME"]
const JULIA_PKG_UUID=ENV["JULIA_PKG_UUID"]
const PKG_VERSION=ENV["PKG_VERSION"]
const JULIA_DEPOT = joinpath(CONDA_PREFIX, "share", "julia")
const BUILD_DEPOT = joinpath(CONDA_PREFIX, "share", "julia_build_depot")

@info "Environment settings" CONDA_PREFIX, JULIA_DEPOT, BUILD_DEPOT

empty!(DEPOT_PATH)
push!(DEPOT_PATH, BUILD_DEPOT)

# A simple adding like this may entail additional network activity
#Pkg.add(JULIA_PKG_NAME)

# Add the local git repository that conda build cloned
uuid = UUID(JULIA_PKG_UUID)
spec = PackageSpec(
    name=JULIA_PKG_NAME,
    uuid=uuid,
    path=joinpath(JULIA_DEPOT, "clones", "$JULIA_PKG_NAME.jl"),
    rev="v$PKG_VERSION"
)
Pkg.add(spec)


# Select certain folders
mkpath(BUILD_DEPOT)
const directories = ("packages", "artifacts")
for directory in directories
    build_dir = joinpath(BUILD_DEPOT, directory)
    target_dir = joinpath(JULIA_DEPOT, directory)
    if isdir(build_dir)
        mv(build_dir, target_dir)
    end
end

# Remove the temporary build depot
rm(BUILD_DEPOT, recursive=true)
