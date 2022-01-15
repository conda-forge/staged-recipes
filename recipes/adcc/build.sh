find adcc -type f -not -name "test_smoke.py" -a -name "*test*.py" -exec rm {} \;
rm -rf adcc/testdata

${PYTHON} setup.py install --prefix=${PREFIX}