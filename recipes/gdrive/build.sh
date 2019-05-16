# Hack to workaround incomplete renaming of gdrive
# xref: https://github.com/gdrive-org/gdrive/issues/461
ln -s "${GOPATH}/src/github.com/gdrive-org" \
      "${GOPATH}/src/github.com/prasmussen"

# Build and install
cd "${GOPATH}/src/github.com/gdrive-org/${PKG_NAME}"
go build -v -o $GOBIN/gdrive .
