set -eufx

# Dropping the verbose option here, +8000 files
cp -a $SRC_DIR/go ${PREFIX}/go

# Right now, it's just go and gofmt, but might be more in the future!
# On linux/macOS we rely on soft-links
mkdir -p ${PREFIX}/bin && pushd $_
find ../go/bin -type f -exec ln -s {} . \;
