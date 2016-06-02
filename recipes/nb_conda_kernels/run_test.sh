cd "${SRC_DIR}"

conda install r-essentials -n _test -c r

"${PREFIX}/bin/npm" install .
"${PREFIX}/bin/npm" run test
