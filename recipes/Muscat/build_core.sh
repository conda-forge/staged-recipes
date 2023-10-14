set -x 
$PYTHON setup.py build_clib 
$PYTHON -m pip install --no-deps . -vv
