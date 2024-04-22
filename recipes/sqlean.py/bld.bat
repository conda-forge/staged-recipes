curl -L https://raw.githubusercontent.com/nalgeon/sqlean.py/%VERSION%/Makefile --no-clobber --output Makefile
mingw32-make prepare-src
mingw32-make download-sqlite
mingw32-make download-sqlean
$PYTHON setup.py build_ext -i
$PYTHON -m pip install .
