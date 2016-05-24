PHANTOMJS_EXECUTABLE=${SRC_DIR}/node_modules/.bin/phantomjs

cd "${SRC_DIR}"
"${PREFIX}/bin/npm" install .
"${PREFIX}/bin/npm" run test
