cd "${SRC_DIR}"

conda install r-irkernel -y -n _test -c r

"${PREFIX}/bin/npm" install .
"${PREFIX}/bin/npm" run test
