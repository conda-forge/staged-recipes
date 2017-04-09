set -e
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
$PYTHON ./bin/build_model all STATIC_FLAG=-static
