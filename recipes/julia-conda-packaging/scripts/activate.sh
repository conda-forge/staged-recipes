#!/bin/sh

julia -e"
using Pkg, UUIDs, TOML
clones_dir=\"${CONDA_PREFIX}/share/julia/conda_clones\"
if !isdir(clones_dir)
    exit(0)
end

function inspect_clones_dir(clones_dir)
    dependencies = Pkg.dependencies()
    packages_to_add = PackageSpec[]
    # Iterate over each child of clones_dir
    for clone in readdir(clones_dir)
        pkgsrc = joinpath(clones_dir, clone)
        project_toml = joinpath(pkgsrc, \"Project.toml\")
        if isdir(pkgsrc) && isfile(project_toml)
            # Parse Project.toml for package info
            project_dict = TOML.parsefile(project_toml)
            uuid = Base.UUID(project_dict[\"uuid\"])
            version = project_dict[\"version\"]
            if !haskey(dependencies, uuid) || dependencies[uuid].version != VersionNumber(version)
                # Move git to .git
                local_git = joinpath(pkgsrc, \".git\")
                local_git_temp = joinpath(pkgsrc, \"git\")
                if !isdir(local_git) && isdir(local_git_temp)
                    mv(local_git_temp, local_git)
                end

                # Add the clone
                if isdir(local_git)
                    name = project_dict[\"name\"]
                    git_rev = \"v\"*version
                    # add from local, packaged git repo
                    spec = PackageSpec(
                        name=name,
                        uuid=uuid,
                        path=pkgsrc,
                        rev=git_rev,
                    )
                    push!(packages_to_add, spec)
                end
            end
        end
    end
    if !isempty(packages_to_add)
        Pkg.add(packages_to_add)
    end
end
inspect_clones_dir(clones_dir)
"
