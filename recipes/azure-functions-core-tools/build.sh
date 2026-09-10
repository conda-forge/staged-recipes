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
license_report="${SRC_DIR}/THIRD_PARTY_NUGET_LICENSES.md"
license_download_dir="${SRC_DIR}/nuget-licenses"

dotnet restore src/Cli/func/Azure.Functions.Cli.csproj \
  --runtime "${rid}" \
  --configfile NuGet.Config \
  -p:NuGetAudit=false

# nuget-license returns 8 when one or more packages have no license metadata.
# Keep those entries in the report, but fail for every other tool error.
set +e
dotnet-project-licenses \
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
    ;;
  linux-*)
    mkdir -p "${PREFIX}/bin"
    printf '%s\n' \
      '#!/bin/sh' \
      'prefix=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)' \
      'export LD_LIBRARY_PATH="${prefix}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"' \
      'exec "${prefix}/libexec/azure-functions-core-tools/func" "$@"' \
      > "${PREFIX}/bin/func"
    chmod +x "${PREFIX}/bin/func" "${appdir}/func"
    ;;
  osx-*)
    mkdir -p "${PREFIX}/bin"
    chmod +x "${appdir}/func"
    ln -s ../libexec/azure-functions-core-tools/func "${PREFIX}/bin/func"
    ;;
esac
