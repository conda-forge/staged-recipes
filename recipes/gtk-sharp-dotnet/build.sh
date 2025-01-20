#!/usr/bin/env bash

set -euxo pipefail

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

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${BUILD_PREFIX}/lib/pkgconfig"

LIBTOOL=$(which libtool)

host_conda_libs="${PREFIX}/Library/lib"
build_conda_libs="${BUILD_PREFIX}/Library/lib"
paths=(
    "${host_conda_libs}/pkgconfig"
    "${build_conda_libs}/pkgconfig"
)

# Loop through the paths and update PKG_CONFIG_PATH
for path in "${paths[@]}"; do
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}${PKG_CONFIG_PATH:+:}${path}"
done
PKG_CONFIG=$(which pkg-config.exe | sed -E 's|^/(\w)|\1:|')
PKG_CONFIG_PATH=$(echo "$PKG_CONFIG_PATH" | sed -E 's|^(\w):|/\1|' | sed -E 's|:(\w):|:/\1|g')

export PKG_CONFIG
export PKG_CONFIG_PATH
export PKG_CONFIG_LIBDIR="${PKG_CONFIG_PATH}"
export PATH="${BUILD_PREFIX}/Library/bin:${PREFIX}/Library/bin${PATH:+:${PATH:-}}"
export CC=x86_64-w64-mingw32-gcc
export AR=x86_64-w64-mingw32-ar
export RANLIB=x86_64-w64-mingw32-ranlib
export STRIP=x86_64-w64-mingw32-strip
export LD=x86_64-w64-mingw32-ld

framework_version=$(dotnet --version | sed -e 's/^\([0-9]*\)\.\([0-9]*\).*/\1.\2/')

# Replace gapi codes
sed -i -E 's/INCLUDES/AM_CPPFLAGS/g' Makefile.am */Makefile.am */*/Makefile.am
sed -i -E 's|\$\(top_builddir\)/parser/gapi\-fixup\.exe||' Makefile.am */Makefile.am */*/Makefile.am
sed -i -E 's|\$\(top_builddir\)/generator/gapi_codegen\.exe||' Makefile.am */Makefile.am */*/Makefile.am
sed -i -E 's/ gapi2?(_|\-)(fixup|parser|codegen|2\.0\.pc)(\.exe)?/ /g' generator/Makefile.am parser/Makefile.am
sed -i -E 's/(noinst_DATA =.*?) \$\(POLICY_ASSEMBLIES\)(.*)/\1\2/g' */Makefile.am

# Replace the builds with dotnet xxx.csproj
create_gapi_csproj "${framework_version}" fixup
python "${RECIPE_DIR}/non-unix-helpers/csproj-modernizer.py" generator "${framework_version}"
export DOTNET_ROOT="$(dirname $(which dotnet))"
for pkg in glib atk gdk cairo gtk pango gtkdotnet; do
  python "${RECIPE_DIR}/non-unix-helpers/csproj-modernizer.py" "${pkg}" "${framework_version}"
  dotnet restore ${pkg}/${pkg}.csproj
  dotnet exec "${BUILD_PREFIX}"/libexec/nuget-license/NuGetLicenseCore.dll --input ${pkg}/${pkg}.csproj -t -d license-files
  sed -i -E "s|CSC\).+|CSC) -c Release ${pkg}.csproj --framework 'net${framework_version}' -p:AssemblyName=\$(ASSEMBLY_NAME) -p:OutputPath=.|" "${pkg}/Makefile.am"
done

libtoolize  # Complains about missing ltmain.sh
NOCONFIGURE=1 ./bootstrap-"$(echo ${PKG_VERSION} | sed -e 's/\.[^.]\+$//')" --prefix=${PREFIX}

# Configure specifically for dotnet on Windows
export CFLAGS="-DDISABLE_GTHREAD_CHECK ${CFLAGS}"
PKG_CONFIG="${PKG_CONFIG}" ./configure \
    --prefix="${PREFIX}" \
    --disable-static

makefiles=(
  "Makefile"
  "atk/Makefile"
  "atk/glue/Makefile"
  "cairo/Makefile"
  "gdk/Makefile"
  "gdk/glue/Makefile"
  "glade/Makefile"
  "glade/glue/Makefile"
  "glib/Makefile"
  "glib/glue/Makefile"
  "gtk/Makefile"
  "gtk/glue/Makefile"
  "gtkdotnet/Makefile"
  "pango/Makefile"
  "pango/glue/Makefile"
)
system_libs_exclude=(
  "uuid" "gdi32" "imm32" "shell32" "usp10" "ole32" "rpcrt4" "shlwapi" "iphlpapi"
  "dnsapi" "ws2_32" "winmm" "msimg32" "dwrite" "d2d1" "windowscodecs" "dl" "m" "dld"
  "svld" "w" "mlib" "dnet" "dnet_stub" "nsl" "bsd" "socket" "posix" "ipc" "XextSan"
  "ICE" "Xinerama" "papi"
)
exclude_regex=$(printf "|%s" "${system_libs_exclude[@]}")
exclude_regex="^(${exclude_regex:1})\$"

python "${RECIPE_DIR}"/non-unix-helpers/replace_l_flags.py \
  --host-dir "$host_conda_libs" \
  --build-dir "$build_conda_libs" \
  --exclude-regex "${exclude_regex}" \
   "${makefiles[@]}"

# It seems that libtool is missing some dynamic libraries to create the .dll
sed -i -E "s|(libatksharpglue_2_la_LIBADD = .*)|\1 -Wl,-L${build_conda_libs} -Wl,-L${host_conda_libs} -Wl,-lglib-2.0 -Wl,-lgobject-2.0 -Wl,-latk-1.0|" atk/glue/Makefile
sed -i -E "s|(libgdksharpglue_2_la_LIBADD = .*)|\1 -Wl,-L${build_conda_libs} -Wl,-L${host_conda_libs} -Wl,-lglib-2.0 -Wl,-lgobject-2.0|" gdk/glue/Makefile
sed -i -E "s|(libgladesharpglue_2_la_LIBADD = .*)|\1|" glade/glue/Makefile
sed -i -E "s|(libglibsharpglue_2_la_LIBADD = .*)|\1 -Wl,-L${build_conda_libs} -Wl,-L${host_conda_libs} -Wl,-lglib-2.0 -Wl,-lgobject-2.0|" glib/glue/Makefile
sed -i -E "s|(libgtksharpglue_2_la_LIBADD = .*)|\1|" gdk/glue/Makefile
sed -i -E "s|(libpangosharpglue_2_la_LIBADD = .*)|\1|" gdk/glue/Makefile
sed -i -E 's|\s\$\(POLICY_ASSEMBLIES\)||g' */Makefile

make
make install
