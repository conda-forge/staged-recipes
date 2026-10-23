#!/usr/bin/env brush
set -euxo pipefail

case "${target_platform}" in
  linux-64|osx-64|win-64) rid="${target_platform%-64}-x64" ;;
  linux-aarch64|osx-arm64|win-arm64) rid="${target_platform%-*}-arm64" ;;
  *) echo "unsupported target platform: ${target_platform}" >&2; exit 1 ;;
esac

case "${target_platform}" in
  win-*) appdir="${LIBRARY_PREFIX}/libexec/azure-functions-core-tools" ;;
  *) appdir="${PREFIX}/libexec/azure-functions-core-tools" ;;
esac

export NUGET_PACKAGES="${SRC_DIR}/.nuget/packages"
export DOTNET_CLI_USE_MSBUILD_SERVER=0
license_report="${SRC_DIR}/THIRD_PARTY_NUGET_LICENSES.md"
license_download_dir="${SRC_DIR}/nuget-licenses"

dotnet restore src/Cli/func/Azure.Functions.Cli.csproj \
  --disable-build-servers \
  --runtime "${rid}" \
  --configfile NuGet.Config \
  -p:NuGetAudit=false

# nuget-license returns 8 when one or more packages have no license metadata.
# Keep those entries in the report, but fail for every other tool error.
set +e
dotnet "${BUILD_PREFIX}/libexec/nuget-license/nuget-license.dll" \
  --input src/Cli/func/Azure.Functions.Cli.csproj \
  --include-transitive \
  --target-framework net10.0 \
  --output Markdown \
  --file-output "${license_report}" \
  --license-information-download-location "${license_download_dir}"
license_status=$?
set -e

case "${license_status}" in
  0|8) ;;
  *) exit "${license_status}" ;;
esac

dotnet publish src/Cli/func/Azure.Functions.Cli.csproj \
  --disable-build-servers \
  --configuration Release \
  --framework net10.0 \
  --runtime "${rid}" \
  --self-contained \
  --no-restore \
  -p:TemplatesJsonZip="${SRC_DIR}/templates.zip" \
  -p:Version="${PKG_VERSION}" \
  --output "${appdir}"

case "${target_platform}" in
  win-*)
    scripts_dir="${PREFIX}\\Scripts"
    cmd.exe /d /c if not exist "${scripts_dir}" mkdir "${scripts_dir}"
    printf '%s\r\n' \
      '@echo off' \
      '"%~dp0..\Library\libexec\azure-functions-core-tools\func.exe" %*' \
      > "${PREFIX}/Scripts/func.cmd"
    # Release MSBuild/Razor/compiler-server handles before rattler-build
    # removes the build and host prefixes.
    dotnet build-server shutdown
    ;;
  linux-*)
    # DT_RPATH is inherited by libraries loaded transitively via dlopen().
    patchelf --force-rpath --set-rpath '$ORIGIN/../../lib' "${appdir}/func"
    mkdir -p "${PREFIX}/bin"
    chmod +x "${appdir}/func"
    ln -s ../libexec/azure-functions-core-tools/func "${PREFIX}/bin/func"
    ;;
  osx-*)
    mkdir -p "${PREFIX}/bin"
    chmod +x "${appdir}/func"
    ln -s ../libexec/azure-functions-core-tools/func "${PREFIX}/bin/func"
    ;;
esac
