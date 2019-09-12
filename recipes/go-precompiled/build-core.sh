set -eufx

#
# Install and source the [de]activate scripts.
for F in deactivate activate; do
  F_DIR="${PREFIX}/etc/conda/${F}.d"
  mkdir -p "${F_DIR}"
  cp -v "${RECIPE_DIR}/${F}-go-${go_variant_str}.sh" "${F_DIR}/${F}_z60-go.sh"
done

source "${F_DIR}/activate_z60-go.sh"

# Dropping the verbose option here, because Travis chokes on output >4MB
cp -a $SRC_DIR/go ${PREFIX}/go

# Right now, it's just go and gofmt, but might be more in the future!
# We don't move files, and instead rely on soft-links
mkdir -p ${PREFIX}/bin && pushd $_
find ../go/bin -type f -exec ln -s {} . \;
