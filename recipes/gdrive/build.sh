# Hack to workaround incomplete renaming of gdrive
# xref: https://github.com/gdrive-org/gdrive/issues/461
ln -s "${GOPATH}/src/github.com/gdrive-org" \
      "${GOPATH}/src/github.com/prasmussen"

# Build and install
# Use linkmode external to workaround a possible Go compiler bug.
# xref: https://github.com/golang/go/issues/23649#issuecomment-493248154
cd "${GOPATH}/src/github.com/gdrive-org/${PKG_NAME}"
go build -v -ldflags="-linkmode=external" -o $GOBIN/gdrive .
