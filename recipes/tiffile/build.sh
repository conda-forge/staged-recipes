tr -d '\015' < tiffile/tifffile.py > tiffile/tifffile.py.unix
mv tiffile/tifffile.py.unix tiffile/tifffile.py

$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
