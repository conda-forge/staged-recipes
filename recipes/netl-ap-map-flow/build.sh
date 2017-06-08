set -e

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
$PYTHON ./bin/build_model all
