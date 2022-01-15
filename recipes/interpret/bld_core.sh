chmod +x build.sh
cd python/interpret-core/
$PYTHON setup.py build
$PYTHON -m pip install --no-deps .

