@REM To avoid <https://github.com/conda/conda/issues/10501>

mkdir C:\tmp
set "TMPDIR=C:\tmp"
pytest -vv --ci -m "not miniconda" test
