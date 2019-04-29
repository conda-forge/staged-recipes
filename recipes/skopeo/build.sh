
PTH="$GOPATH/src/github.com/containers/skopeo"
mkdir -p "$PTH"
mv * "$PTH" || true
cp $PTH/LICENSE .
cd $PTH
make binary-local DISABLE_CGO=1
install -m 755 skopeo $PREFIX/bin/skopeo

