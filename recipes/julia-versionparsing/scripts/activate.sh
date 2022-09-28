#!/bin/sh

name="VersionParsing"
uuid="81def892-9a0e-5fdd-b105-ffc91e053289"

julia -e"
using Pkg, UUIDs
uuid = UUID(\"${uuid}\"); nothing # suppress output
if !haskey(Pkg.dependencies(), uuid)
    spec = PackageSpec(
        name=\"${name}\",
        uuid=uuid,
        path=\"${CONDA_PREFIX}/share/julia/clones/VersionParsing.jl\",
    )
    Pkg.add(spec)
end
"
