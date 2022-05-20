set -ex

$PYTHON -c "import dolfinx"
pip check

pytest -vx python/test
