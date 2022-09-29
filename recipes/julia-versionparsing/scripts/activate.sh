#!/bin/sh

# build_base.sh will insert lines defining name, uuid, and version

pkgsrc="${CONDA_PREFIX}/share/julia/clones/$name.jl"

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
