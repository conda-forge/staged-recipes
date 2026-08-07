#!/usr/bin/env bash
# mostly cribbed from https://github.com/conda-forge/nuget-license-feedstock/blob/main/recipe/build.sh

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/libexec/${PKG_NAME}"
ln -sf "${DOTNET_ROOT}/dotnet" "${PREFIX}/bin"

dotnet publish \
  --no-self-contained "${SRC_DIR}/src/cyclonedx/cyclonedx.csproj" \
  --configuration=Release \
  --output="${PREFIX}/libexec/${PKG_NAME}" \
  --framework="net${CF_DOTNET_MAJOR}"

mkdir -p "${PREFIX}/bin"
rm -rf "${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME}"

tee "${PREFIX}/bin/${PKG_NAME}" << EOF
#!/bin/sh
exec "${DOTNET_ROOT}/dotnet" exec "${PREFIX}/libexec/cyclonedx-cli/cyclonedx.dll" "\$@"
EOF

chmod +x "${PREFIX}/bin/cyclonedx-cli"

tee "${PREFIX}/bin/${PKG_NAME}.cmd" << EOF
call "%DOTNET_ROOT%\dotnet" exec "%CONDA_PREFIX%\libexec\cyclonedx-cli\cyclonedx.dll" %*
EOF

dotnet-project-licenses \
  --input="${SRC_DIR}/src/cyclonedx/cyclonedx.csproj" \
  --file-output=licenses-release.json \
  --output=JsonPretty \
  --license-information-download-location=license-files

rm "${PREFIX}/bin/dotnet"
