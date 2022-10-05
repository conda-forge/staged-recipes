#!/bin/sh

# build_base.sh will insert lines defining name, uuid, version, and git_url

pkgsrc="${CONDA_PREFIX}/share/julia/clones/$name.jl"

julia -e"
using Pkg, UUIDs
name = \"${name}\"
uuid = UUID(\"${uuid}\")
version_str = \"${version}\"
version = v\"${version}\"
git_rev = \"v${version}\"
pkgsrc = \"${pkgsrc}\"
local_git = joinpath(pkgsrc, \".git\")
local_git_temp = joinpath(pkgsrc, \"git\")
remote_git = \"${git_url}\"
if !haskey(Pkg.dependencies(), uuid)
    if !isdir(local_git) && isdir(local_git_temp)
        # Move git to .git
        mv(local_git_temp, local_git)
    end
    if isdir(local_git)
        # Add from local, packaged git repo
        spec = PackageSpec(
            name=name,
            uuid=uuid,
            path=pkgsrc,
            rev=git_rev,
        )
        Pkg.add(spec)
    elseif isdir(pkgsrc)
        # Dev without git
        spec = PackageSpec(
            name=name,
            uuid=uuid,
            path=pkgsrc,
        )
        Pkg.develop(spec)
    elseif !isempty(remote_git)
        # Add from internet git repo
        spec = PackageSpec(
            name=name,
            uuid=uuid,
            url=remote_git,
            rev=git_rev,
        )
        Pkg.add(spec)
    else
        # Add via Julia registry / JULIA_PKG_SERVER
        spec = PackageSpec(
            name=name,
            uuid=uuid,
            version=version,
        )
        Pkg.add(spec)
    end
end
"
