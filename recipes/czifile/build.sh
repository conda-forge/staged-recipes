tr -d '\015' < czifile/czifile.py > czifile/czifile.py.unix
mv czifile/czifile.py.unix czifile/czifile.py
$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
