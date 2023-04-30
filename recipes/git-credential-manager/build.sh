set -ex

dotnet tool install git-credential-manager \
  --tool-path "${DOTNET_TOOLS}" \
  --add-source "${SRC_DIR}" \
  --verbosity diagnostic \
  ;
