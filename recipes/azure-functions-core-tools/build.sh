#!/usr/bin/env brush
set -euxo pipefail

case "${target_platform}" in
  linux-64)
    rid=linux-x64
    appdir="${PREFIX}/libexec/azure-functions-core-tools"
    ;;
  linux-aarch64)
    rid=linux-arm64
    appdir="${PREFIX}/libexec/azure-functions-core-tools"
    ;;
  osx-64)
    rid=osx-x64
    appdir="${PREFIX}/libexec/azure-functions-core-tools"
    ;;
  osx-arm64)
    rid=osx-arm64
    appdir="${PREFIX}/libexec/azure-functions-core-tools"
    ;;
  win-64)
    rid=win-x64
    appdir="${LIBRARY_PREFIX}/libexec/azure-functions-core-tools"
    ;;
  win-arm64)
    rid=win-arm64
    appdir="${LIBRARY_PREFIX}/libexec/azure-functions-core-tools"
    ;;
  *) echo "unsupported target platform: ${target_platform}" >&2; exit 1 ;;
esac

export NUGET_PACKAGES="${SRC_DIR}/.nuget/packages"

dotnet restore src/Cli/func/Azure.Functions.Cli.csproj \
  --runtime "${rid}" \
  --configfile NuGet.Config \
  -p:NuGetAudit=false

dotnet-project-licenses \
  --input src/Cli/func/Azure.Functions.Cli.csproj \
  --include-transitive \
  --target-framework net10.0 \
  --output Markdown \
  --file-output "${SRC_DIR}/THIRD_PARTY_NUGET_LICENSES.md" \
  --license-information-download-location "${SRC_DIR}/nuget-licenses"

dotnet publish src/Cli/func/Azure.Functions.Cli.csproj \
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
    cmd.exe /d /c "if not exist \"${PREFIX}/Scripts\" mkdir \"${PREFIX}/Scripts\""
    printf '%s\r\n' \
      '@echo off' \
      '"%~dp0..\Library\libexec\azure-functions-core-tools\func.exe" %*' \
      > "${PREFIX}/Scripts/func.cmd"
    ;;
  *)
    mkdir -p "${PREFIX}/bin"
    chmod +x "${appdir}/func"
    ln -s ../libexec/azure-functions-core-tools/func "${PREFIX}/bin/func"
    ;;
esac
