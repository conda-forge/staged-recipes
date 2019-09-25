mkdir -p ${PREFIX}/etc/conda/{de,}activate.d
cp "${SRC_DIR}"/activate-g++.sh ${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh
cp "${SRC_DIR}"/deactivate-g++.sh ${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh
