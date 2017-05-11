%PYTHON% setup.py build --enable-all-extensions
%PYTHON% setup.py install --single-version-externally-managed --record record.txt
%PYTHON% setup.py test
