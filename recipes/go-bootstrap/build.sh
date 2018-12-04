# Build go1.4 using gcc
export CGO_ENABLED=0
pushd ${PKG_NAME}/src
./make.bash
popd

# Dropping the verbose option here, because Travis chokes on output >4MB
cp -a $SRC_DIR/${PKG_NAME} ${PREFIX}/

# Copy the rendered [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
for F in activate deactivate; do
  mkdir -p "${PREFIX}/etc/conda/${F}.d"
  cp -v "${RECIPE_DIR}/${F}-${PKG_NAME}.sh" "${PREFIX}/etc/conda/${F}.d/${F}-${PKG_NAME}.sh"
done
