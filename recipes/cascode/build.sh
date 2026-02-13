#!/usr/bin/env bash
set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/libexec/${PKG_NAME}"
ln -sf "${DOTNET_ROOT}/dotnet" "${PREFIX}/bin"

dotnet publish tools/cli/Cascode.Cli.csproj \
  --no-self-contained \
  -c Release \
  -o "${PREFIX}/libexec/${PKG_NAME}"

# Keep only runtime assets for conda-forge target platforms. Publishing
# without an RID pulls in many non-conda runtimes (android/ios/browser/etc.).
if [ -d "${PREFIX}/libexec/${PKG_NAME}/runtimes" ]; then
  pushd "${PREFIX}/libexec/${PKG_NAME}/runtimes" >/dev/null
  for rid_dir in *; do
    case "${rid_dir}" in
      linux-x64|linux-arm64|osx-x64|osx-arm64|win-x64) ;;
      *) rm -rf "${rid_dir}" ;;
    esac
  done
  popd >/dev/null
fi

rm -f "${PREFIX}/libexec/${PKG_NAME}/Cascode.Cli"

tee "${PREFIX}/bin/cascode" << 'EOF'
#!/bin/sh
exec "${DOTNET_ROOT}/dotnet" exec "${CONDA_PREFIX}/libexec/cascode/Cascode.Cli.dll" "$@"
EOF
chmod +x "${PREFIX}/bin/cascode"

tee "${PREFIX}/bin/cascode.cmd" << 'EOF'
call "%DOTNET_ROOT%\dotnet" exec "%CONDA_PREFIX%\libexec\cascode\Cascode.Cli.dll" %*
EOF

rm -f "${PREFIX}/bin/dotnet"
