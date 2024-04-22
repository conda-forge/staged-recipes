curl -L https://raw.githubusercontent.com/nalgeon/sqlean.py/%VERSION%/Makefile --output Makefile
mkdir sqlite
mingw32-make download-sqlite
mingw32-make download-sqlean
%PYTHON% setup.py build_ext -i
%PYTHON% -m pip install .
