set -exuo pipefail


go build -trimpath  -o "${BINARY_FILEPATH}"

go-licenses save . --save_path ./thirdparty --ignore github.com/tmccombs/hcl2json

# Clear out cache to avoid file not removable warnings
chmod -R u+w $(go env GOPATH) && rm -r $(go env GOPATH)
