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

make_dir() {
  case "${target_platform}" in
    win-*) cmd.exe /d /c "if not exist \"${1}\" mkdir \"${1}\"" ;;
    *) mkdir -p "${1}" ;;
  esac
}

copy_file() {
  case "${target_platform}" in
    win-*) cmd.exe /d /c "copy /y \"${1}\" \"${2}\" >nul" ;;
    *) cp "${1}" "${2}" ;;
  esac
}

export NUGET_PACKAGES="${SRC_DIR}/.nuget/packages"
license_dir="${SRC_DIR}/collected-licenses"
make_dir "${license_dir}"
make_dir "${SRC_DIR}/nuget-licenses"

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
  --file-output "${SRC_DIR}/THIRD_PARTY_NUGET_LICENSES.md" \
  --license-information-download-location "${SRC_DIR}/nuget-licenses"
license_status=$?
set -e

case "${license_status}" in
  0|8) ;;
  *) exit "${license_status}" ;;
esac

# Framework and host packs are brought in by self-contained publish as
# download dependencies, so nuget-license does not include them in its report.
for runtime_package in \
  "microsoft.netcore.app.runtime.${rid}" \
  "microsoft.aspnetcore.app.runtime.${rid}" \
  "microsoft.netcore.app.host.${rid}"
do
  for license_file in "${NUGET_PACKAGES}/${runtime_package}"/*/LICENSE.*
  do
    if [ -f "${license_file}" ]; then
      copy_file "${license_file}" "${license_dir}/${runtime_package}-LICENSE.txt"
    fi
  done

  for notice_file in "${NUGET_PACKAGES}/${runtime_package}"/*/THIRD-PARTY-NOTICES.*
  do
    if [ -f "${notice_file}" ]; then
      copy_file "${notice_file}" "${license_dir}/${runtime_package}-THIRD-PARTY-NOTICES.txt"
    fi
  done
done

dotnet publish src/Cli/func/Azure.Functions.Cli.csproj \
  --configuration Release \
  --framework net10.0 \
  --runtime "${rid}" \
  --self-contained \
  --no-restore \
  -p:TemplatesJsonZip="${SRC_DIR}/templates.zip" \
  -p:Version="${PKG_VERSION}" \
  --output "${appdir}"

# These files are already shipped with the Node worker. Also expose them via
# the conda package's info/licenses directory.
if [ -f "${appdir}/workers/node/LICENSE" ]; then
  copy_file "${appdir}/workers/node/LICENSE" "${license_dir}/azure-functions-nodejs-worker-LICENSE.txt"
fi
if [ -f "${appdir}/workers/node/NOTICE.html" ]; then
  copy_file "${appdir}/workers/node/NOTICE.html" "${license_dir}/azure-functions-nodejs-worker-NOTICE.html"
fi

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
