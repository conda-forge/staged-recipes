export DATADIR="${PREFIX}/share/proj"
mkdir -p ${DATADIR}

cp -r ${PKG_NAME}/* ${DATADIR}
