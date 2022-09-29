#!/bin/sh

name="VersionParsing"
uuid="81def892-9a0e-5fdd-b105-ffc91e053289"
version="1.3.0"
pkgsrc="${CONDA_PREFIX}/share/julia/clones/VersionParsing.jl"

julia -e"
using Pkg, UUIDs
uuid = UUID(\"${uuid}\");
if !haskey(Pkg.dependencies(), uuid)
    if !isdir(\"${pkgsrc}/.git\")
        mv(\"${pkgsrc}/git\",\"${pkgsrc}/.git\")
    end
    spec = PackageSpec(
        name=\"${name}\",
        uuid=uuid,
        path=\"${pkgsrc}\",
        rev=\"v${version}\",
    )
    Pkg.add(spec)
end
"
