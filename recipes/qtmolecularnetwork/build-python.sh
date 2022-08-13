set -ex

$PYTHON -m pip install . --no-build-isolation \
    --no-deps --ignore-installed --no-index --no-cache-dir -vv
