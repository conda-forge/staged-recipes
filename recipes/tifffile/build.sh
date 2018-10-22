tr -d '\015' < tifffile/tifffile.py > tifffile/tifffile.py.unix
mv tifffile/tifffile.py.unix tifffile/tifffile.py

$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
