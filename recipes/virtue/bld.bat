flit build --format wheel
python -m pip install --no-deps dist/*.whl -vv
