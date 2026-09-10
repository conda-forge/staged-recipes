#!/usr/bin/env bash
set -exo pipefail

case "${target_platform}" in
  linux-64) rid=linux-x64 ;;
  linux-aarch64) rid=linux-arm64 ;;
  osx-64) rid=osx-x64 ;;
  osx-arm64) rid=osx-arm64 ;;
  *) echo "unsupported target platform: ${target_platform}" >&2; exit 1 ;;
esac

export NUGET_PACKAGES="${SRC_DIR}/.nuget/packages"
publish_dir="${SRC_DIR}/out/conda/${rid}"

dotnet restore src/Cli/func/Azure.Functions.Cli.csproj \
  --runtime "${rid}" \
  --configfile NuGet.Config \
  -p:NuGetAudit=false

dotnet publish src/Cli/func/Azure.Functions.Cli.csproj \
  --configuration Release \
  --framework net10.0 \
  --runtime "${rid}" \
  --self-contained \
  --no-restore \
  -p:TemplatesJsonZip="${SRC_DIR}/templates.zip" \
  -p:Version="${PKG_VERSION}" \
  --output "${publish_dir}"

appdir="${PREFIX}/libexec/azure-functions-core-tools"
mkdir -p "${appdir}" "${PREFIX}/bin"
cp -a "${publish_dir}/." "${appdir}/"
chmod +x "${appdir}/func"
ln -s ../libexec/azure-functions-core-tools/func "${PREFIX}/bin/func"
