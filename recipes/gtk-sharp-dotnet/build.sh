#!/usr/bin/env bash

merge_custom() {
    local pkg=$1
    # For each .custom file
    mkdir -p "${pkg}/merged"
    for custom in ${pkg}/*.custom; do
        if [ -f "$custom" ]; then
            base=$(basename "$custom" .custom)
            gen="${pkg}/generated/${base}.cs"
            merged="${pkg}/merged/${base}.cs"
            if [ -f "$gen" ]; then
                # Count closing braces at the end of generated file
                closing_braces=$(grep -c "^}$" "$gen")
                # Create merged file without the closing braces
                head -n -${closing_braces} "$gen" > "$merged"
                # Add custom content
                tail -n +2 "$custom" >> "$merged"  # Skip first line (comment)
                # Add back closing braces
                for ((i=0; i<closing_braces; i++)); do
                    echo "}" >> "$merged"
                done
            else
                echo "Warning: no generated file for $custom"
            fi
        fi
    done
}

convert_proj() {
    local pkg=$1
    local namespace="${2:-$(tr '[:lower:]' '[:upper:]' <<< ${pkg:0:1})${pkg:1}}"

    cat > ${pkg}/${pkg}.csproj << EOF
<?xml version="1.0" encoding="utf-8"?>
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <OutputType>Library</OutputType>
    <RootNamespace>${namespace}</RootNamespace>
    <AssemblyName>${pkg}</AssemblyName>
    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>
    <NoWarn>0649;1616;1699</NoWarn>
    <DefineConstants>GTK_SHARP_2_6;GTK_SHARP_2_8;GTK_SHARP_2_10;GTK_SHARP_2_12</DefineConstants>
    <SignAssembly>true</SignAssembly>
    <AssemblyOriginatorKeyFile>../gtk-sharp.snk</AssemblyOriginatorKeyFile>
    <GenerateAssemblyInfo>false</GenerateAssemblyInfo>
    <EnableDefaultCompileItems>false</EnableDefaultCompileItems>
  </PropertyGroup>

  <ItemGroup>
EOF

    # First merge custom files with generated
    merge_custom ${pkg}

    echo "    <Compile Include=\"../AssemblyInfo.cs\" />" >> ${pkg}/${pkg}.csproj

    # First add regular .cs files
    for csfile in ${pkg}/*.cs; do
        if [ -f "$csfile" ]; then
            base=$(basename "$csfile" .cs)
            echo "    <Compile Include=\"$(basename "$csfile")\" />" >> ${pkg}/${pkg}.csproj
        fi
    done

    # Then add generated files
    if [ -d "${pkg}/generated" ]; then
        for gen in ${pkg}/generated/*.cs; do
            if [ -f "$gen" ]; then
                base=$(basename "$gen" .cs)
                if [ -f "${pkg}/merged/${base}.cs" ]; then
                    echo "    <Compile Include=\"merged/${base}.cs\" />" >> ${pkg}/${pkg}.csproj
                else
                    # Only include generated file if there's no source version
                    if [ ! -f "${pkg}/${base}.cs" ]; then
                        echo "    <Compile Include=\"generated/${base}.cs\" />" >> ${pkg}/${pkg}.csproj
                    fi
                fi
            fi
        done
    fi

    echo "  </ItemGroup>" >> ${pkg}/${pkg}.csproj
    echo "  <ItemGroup>" >> ${pkg}/${pkg}.csproj

    case ${pkg} in
        atk|gdk|pango)
            echo "    <ProjectReference Include=\"../glib/glib.csproj\">" >> ${pkg}/${pkg}.csproj
            echo "      <Name>glib</Name>" >> ${pkg}/${pkg}.csproj
            echo "    </ProjectReference>" >> ${pkg}/${pkg}.csproj
            ;;
        gtk)
            echo "    <ProjectReference Include=\"../glib/glib.csproj\">" >> ${pkg}/${pkg}.csproj
            echo "      <Name>glib</Name>" >> ${pkg}/${pkg}.csproj
            echo "    </ProjectReference>" >> ${pkg}/${pkg}.csproj
            echo "    <ProjectReference Include=\"../gdk/gdk.csproj\">" >> ${pkg}/${pkg}.csproj
            echo "      <Name>gdk</Name>" >> ${pkg}/${pkg}.csproj
            echo "    </ProjectReference>" >> ${pkg}/${pkg}.csproj
            echo "    <ProjectReference Include=\"../pango/pango.csproj\">" >> ${pkg}/${pkg}.csproj
            echo "      <Name>pango</Name>" >> ${pkg}/${pkg}.csproj
            echo "    </ProjectReference>" >> ${pkg}/${pkg}.csproj
            ;;
    esac

    echo "  </ItemGroup>" >> ${pkg}/${pkg}.csproj
    echo "</Project>" >> ${pkg}/${pkg}.csproj

    dotnet restore ${pkg}/${pkg}.csproj
}

convert_gtkdotnet() {
    cat > gtkdotnet/gtkdotnet.csproj << EOF
<?xml version="1.0" encoding="utf-8"?>
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <OutputType>Library</OutputType>
    <RootNamespace>Gtk.DotNet</RootNamespace>
    <AssemblyName>gtkdotnet</AssemblyName>
    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>
    <NoWarn>0618;0169;0612;0414;1616;1699</NoWarn>
    <DefineConstants>DEBUG;GTK_SHARP_2_6;GTK_SHARP_2_8;GTK_SHARP_2_10;GTK_SHARP_2_12</DefineConstants>
    <SignAssembly>true</SignAssembly>
    <AssemblyOriginatorKeyFile>../gtk-sharp.snk</AssemblyOriginatorKeyFile>
    <RuntimeIdentifier>win-x64</RuntimeIdentifier>
    <PlatformTarget>x64</PlatformTarget>
    <NativeLibrarySearchPaths>\$(PREFIX)/Library/bin</NativeLibrarySearchPaths>
    <GenerateAssemblyInfo>false</GenerateAssemblyInfo>
  </PropertyGroup>

  <ItemGroup>
    <ProjectReference Include="../gdk/gdk.csproj" />
    <PackageReference Include="System.Drawing.Common" Version="8.0.0" />
  </ItemGroup>
</Project>
EOF

    dotnet restore gtkdotnet/gtkdotnet.csproj
}

# For generator, which is likely different as it's an executable:
convert_generator_proj() {
    cat > generator/generator.csproj << EOF
<?xml version="1.0" encoding="utf-8"?>
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <OutputType>Exe</OutputType>
    <RootNamespace>GtkSharp.Generation</RootNamespace>
    <AssemblyName>generator</AssemblyName>
    <EnableDefaultCompileItems>false</EnableDefaultCompileItems>
    <InvariantGlobalization>true</InvariantGlobalization>
    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>
    <NoWarn>0618;0169;0612;0414;1616;1699</NoWarn>
    <SignAssembly>true</SignAssembly>
    <AssemblyOriginatorKeyFile>../gtk-sharp.snk</AssemblyOriginatorKeyFile>
    <GenerateAssemblyInfo>false</GenerateAssemblyInfo>
  </PropertyGroup>
  <ItemGroup>
    <Compile Include="*.cs" />
  </ItemGroup>
</Project>
EOF

    dotnet restore generator/generator.csproj
    dotnet build -c Release generator/generator.csproj
}

generate_bindings() {
    local pkg=$1
    local namespace="${2:-$(tr '[:lower:]' '[:upper:]' <<< ${pkg:0:1})${pkg:1}}"

    # Create generated directory if it doesn't exist
    mkdir -p ${pkg}/generated

    # Different packages use different file naming patterns
    local api_file=""
    if [ -f "${pkg}/${pkg}-api.xml" ]; then
        api_file="${pkg}/${pkg}-api.xml"
    elif [ -f "${pkg}/${pkg}-symbols.xml" ]; then
        api_file="${pkg}/${pkg}-symbols.xml"
    elif [ -f "${pkg}/${pkg}-api-2.12.raw" ]; then
        api_file="${pkg}/${pkg}-api-2.12.raw"
    fi

    local meta_file=""
    if [ -f "${pkg}/${namespace}.metadata" ]; then
        meta_file="-I:${pkg}/${namespace}.metadata"
    fi

    # Run generator on the API file
    if [ -n "$api_file" ]; then
        dotnet run --project generator/generator.csproj \
            --outdir=${pkg}/generated \
            --generate \
            "${api_file}" \
            "${meta_file}"
    fi
}

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${DOTNET_ROOT}/dotnet ${PREFIX}/bin

framework_version=$(dotnet --version | sed -e 's/^\([0-9]*\)\.\([0-9]*\).*/\1.\2/')

convert_generator_proj

for pkg in glib atk gdk cairo gtk pango; do
  generate_bindings ${pkg}
  convert_proj ${pkg}
  dotnet-project-licenses --input ${pkg}/${pkg}.csproj -t -d license-files
done
convert_gtkdotnet
convert_generator_proj
dotnet-project-licenses --input gtkdotnet/gtkdotnet.csproj -t -d license-files

# Clean old build artifacts
for pkg in glib atk gdk cairo gtk pango gtkdotnet generator; do
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
dotnet build -c Release generator/generator.csproj --framework "net${framework_version}"

dotnet build -c Release gtk-sharp.sln --framework "net${framework_version}"
