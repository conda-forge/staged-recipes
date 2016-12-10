conda install --yes nodejs
# FIXME: Same hack as build.sh

cd "${SRC_DIR}"
"${PREFIX}/bin/npm" install .
"${PREFIX}/bin/npm" run tests
