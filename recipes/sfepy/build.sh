export CFLAGS='-I${PREFIX}/include/python3.5m -I${PREFIX}/include/python3.4m'
$PYTHON setup.py install --single-version-externally-managed --record record.txt
