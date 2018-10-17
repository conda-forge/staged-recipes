tr -d '\015' < zisraw/czifile.py > zisraw/czifile.py.unix
mv zisraw/czifile.py.unix zisraw/czifile.py
$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
