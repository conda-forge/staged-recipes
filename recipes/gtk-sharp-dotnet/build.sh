#!/usr/bin/env bash

create_gapi_csproj() {
  local framework_version=$1
  local gapi_call=$2
    cat > "parser/gapi-${gapi_call}.csproj" << EOF
<?xml version="1.0" encoding="utf-8"?>
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>
    <GenerateAssemblyInfo>false</GenerateAssemblyInfo>
    <EnableDefaultCompileItems>false</EnableDefaultCompileItems>
    <InvariantGlobalization>true</InvariantGlobalization>
EOF
    echo "    <TargetFramework>net${framework_version}</TargetFramework>" >> "parser/gapi-${gapi_call}.csproj"
    cat >> "parser/gapi-${gapi_call}.csproj" << EOF

  </PropertyGroup>

  <ItemGroup>
EOF
    echo "    <Compile Include=\"gapi-${gapi_call}.cs\" />" >> "parser/gapi-${gapi_call}.csproj"
    cat >> "parser/gapi-${gapi_call}.csproj" << EOF
  </ItemGroup>
</Project>
EOF
}

generate_bindings() {
    local pkg=$1
    local namespace="${2:-$(tr '[:lower:]' '[:upper:]' <<< ${pkg:0:1})${pkg:1}}"
    # Create generated directory if it doesn't exist
    mkdir -p ${pkg}/generated

    # Process main API file
    if [ -f "${pkg}/${pkg}-api-2.12.raw" ]; then
        if [ ! -f "${pkg}/${pkg}-api.xml" ] || [ "${pkg}/${pkg}-api-2.12.raw" -nt "${pkg}/${pkg}-api.xml" ]; then
            cp "${pkg}/${pkg}-api-2.12.raw" "${pkg}/${pkg}-api.xml"
            chmod u+w "${pkg}/${pkg}-api.xml"
            if [ -f "${pkg}/${namespace}.metadata" ]; then
                dotnet run --project parser/gapi-fixup.csproj \
                    --api="${pkg}/${pkg}-api.xml" \
                    --metadata="${pkg}/${namespace}.metadata"
            fi
        fi
        dotnet run --project generator/generator.csproj \
            --generate "${pkg}/${pkg}-api.xml" \
            --outdir=${pkg}/generated \
            --customdir=${pkg}
    elif [ -f "${pkg}/${pkg}-api.xml" ]; then
        if [ -f "${pkg}/${namespace}.metadata" ]; then
            dotnet run --project parser/gapi-fixup.csproj \
                --api="${pkg}/${pkg}-api.xml" \
                --metadata="${pkg}/${namespace}.metadata"
        fi
        dotnet run --project generator/generator.csproj \
            --generate "${pkg}/${pkg}-api.xml" \
            --outdir=${pkg}/generated \
            --customdir=${pkg}
    fi

    # Process symbols if they exist
    if [ -f "${pkg}/${pkg}-symbols.xml" ]; then
        dotnet run --project generator/generator.csproj \
            --generate "${pkg}/${pkg}-symbols.xml" \
            --outdir=${pkg}/generated \
            --customdir=${pkg}
    fi
}

process_assembly_info() {
    # Create AssemblyInfo.cs from template if it doesn't exist
    if [ ! -f "AssemblyInfo.cs" ] && [ -f "AssemblyInfo.cs.in" ]; then
        # Use API_VERSION from PKG_VERSION (first two components)
        local api_version=$(echo "${PKG_VERSION}" | cut -d. -f1,2)
        sed -e "s/@API_VERSION@/${api_version}/g" \
            AssemblyInfo.cs.in > "AssemblyInfo.cs"
    fi
}

set -o xtrace -o nounset -o pipefail -o errexit

# Split off last part of the version string
./bootstrap-$(echo "${PKG_VERSION}" | sed -e 's/\.[^.]\+$//') --prefix=${PREFIX}
./configure --prefix=${PREFIX} --enable-dotnet || true
exit 1
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${DOTNET_ROOT}/dotnet ${PREFIX}/bin

framework_version=$(dotnet --version | sed -e 's/^\([0-9]*\)\.\([0-9]*\).*/\1.\2/')

process_assembly_info
create_gapi_csproj ${framework_version} fixup

cp ${SRC_DIR}/AssemblyInfo.cs generator/AssemblyInfo.cs
python ${RECIPE_DIR}/csproj-modernizer.py generator ${framework_version}
rm -rf generator/generated generator/bin generator/obj
dotnet restore generator/generator.csproj
dotnet build -c Release generator/generator.csproj --framework "net${framework_version}"

for pkg in glib atk gdk cairo gtk pango gtkdotnet; do
  cp ${SRC_DIR}/AssemblyInfo.cs ${pkg}/AssemblyInfo.cs
  python ${RECIPE_DIR}/csproj-modernizer.py ${pkg} ${framework_version}
  generate_bindings ${pkg}
  cp ${pkg}/*.custom ${pkg}/generated 2>/dev/null || echo "No .custom files to copy."
  dotnet restore ${pkg}/${pkg}.csproj
  dotnet-project-licenses --input ${pkg}/${pkg}.csproj -t -d license-files
  rm -rf ${pkg}/bin ${pkg}/obj
done

# Build in dependency order
dotnet build -c Release glib/glib.csproj --framework "net${framework_version}"
dotnet build -c Release atk/atk.csproj --framework "net${framework_version}"
dotnet build -c Release cairo/cairo.csproj --framework "net${framework_version}"
dotnet build -c Release pango/pango.csproj --framework "net${framework_version}"
dotnet build -c Release gdk/gdk.csproj --framework "net${framework_version}"
dotnet build -c Release gtk/gtk.csproj --framework "net${framework_version}"
dotnet build -c Release gtkdotnet/gtkdotnet.csproj --framework "net${framework_version}"

dotnet build -c Release gtk-sharp.sln --framework "net${framework_version}"

}