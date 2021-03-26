if [ -d ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION} ]; then
    DIR=${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}
else
    DIR=${SRC_DIR}
fi
for subfolder in "bin" "class" "dist" "lib" "sample-data" "stoplists" "LICENSE" "README.md"; do
    cp -r ${DIR}/${subfolder} ${PREFIX}
done