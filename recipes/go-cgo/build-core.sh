set -eufx

#
# Install and source the [de]activate scripts.
for F in deactivate activate; do
  F_DIR="${PREFIX}/etc/conda/${F}.d"
  mkdir -p "${F_DIR}"
  cp -v "${RECIPE_DIR}/${F}-go-${go_variant_str}.sh" "${F_DIR}/${F}_z60-go.sh"
done

source "${F_DIR}/activate_z60-go.sh"

# Set the CC and CXX TARGETS
export CC_FOR_TARGET=${CC}
export CXX_FOR_TARGET=${CXX}
unset CGO_LDFLAGS

# Do not use GOROOT_FINAL. Otherwise, every conda environment would
# need its own non-hardlinked copy of the go (+100MB per env).
# It is better to rely on setting GOROOT during environment activation.
#
# c.f. https://github.com/conda-forge/go-feedstock/pull/21#discussion_r202513916
export GOROOT=$SRC_DIR/go
export GOCACHE=off

# This is a fix for user.Current issue
export USER="${USER:-conda}"
export HOME="${HOME:-$(cd $SRC_DIR/..;pwd)}"
# This is a fix for golang/go#23888
if [ -x "${ADDR2LINE:-}" ]; then 
  ln $ADDR2LINE $(dirname $ADDR2LINE)/addr2line
fi

pushd $GOROOT/src
./make.bash -v
popd

# Don't need the cached build objects
rm -fr ${GOROOT}/pkg/obj

# Dropping the verbose option here, because Travis chokes on output >4MB
cp -av ${GOROOT} ${PREFIX}/go

# Right now, it's just go and gofmt, but might be more in the future!
# We don't move files, and instead rely on soft-links
mkdir -p ${PREFIX}/bin && pushd $_
find ../go/bin -type f -exec ln -s {} . \;
