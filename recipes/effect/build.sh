if [[ $PY_VER == 2* ]]; then
    rm effect/_test_do_py3.py
fi
python setup.py install --single-version-externally-managed --record record.txt
