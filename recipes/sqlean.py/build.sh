curl -L https://raw.githubusercontent.com/nalgeon/sqlean.py/$VERSION/Makefile --no-clobber --output Makefile
make prepare-src
make download-sqlite
make download-sqlean
$PYTHON setup.py build_ext -i
$PYTHON -m pip install .
