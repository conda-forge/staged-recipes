#!/bin/sh

export name="VersionParsing"
export uuid="81def892-9a0e-5fdd-b105-ffc91e053289"
export version="1.3.0"

julia <<JULIA_PACKAGE_INSTALL_SCRIPT
using Pkg, UUIDs
uuid = UUID("${uuid}"); nothing # suppress output
if !haskey(Pkg.dependencies(), uuid)
    Pkg.add(PackageSpec(name="${name}", uuid="${uuid}", version="${version}"))
end
JULIA_PACKAGE_INSTALL_SCRIPT
