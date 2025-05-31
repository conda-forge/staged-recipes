set -exuo pipefail


echo "PKG_VERSION = ${PKG_VERSION}"

go build -trimpath  -ldflags "-X main.version=0.6.7" -o "${BINARY_FILEPATH}"
go build \
    -trimpath \
    -ldflags "-X main.version=${PKG_VERSION}" \
    -o "${BINARY_FILEPATH}"


go-licenses save . --save_path ./thirdparty --ignore github.com/tmccombs/hcl2json

# Clear out cache to avoid file not removable warnings
chmod -R u+w $(go env GOPATH) && rm -r $(go env GOPATH)
