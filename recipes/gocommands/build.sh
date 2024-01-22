PKG=github.com/cyverse/gocommands
VERSION=v${PKG_VERSION}
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LDFLAGS="-X '${PKG}/commons.clientVersion=${VERSION}' -X '${PKG}/commons.buildDate=${BUILD_DATE}'"
GO111MODULE=on
GOPROXY=direct
GOPATH=$(go env GOPATH)
CGO_ENABLED=0 

mkdir -p ${PREFIX}/bin
echo "building gocommands"
go build -v "-ldflags=${LDFLAGS}" -o gocmd ./cmd/gocmd.go
cp gocmd ${PREFIX}/bin/gocmd
