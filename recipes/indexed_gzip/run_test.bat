:: Apply patch to `subprocess` on Python versions > 2 and < 3.6.3
:: https://github.com/matplotlib/matplotlib/issues/9176
for /f "delims=" %%a in ('python -c "import subprocess; import os.path as op; print(op.abspath(op.join(op.dirname(subprocess.__file__), "".."")));"') do @set PATCH_PREFIX=%%a


python -c "import sys; sys.exit(not (3,) < sys.version_info < (3,6,3))" && (curl -sL https://github.com/python/cpython/pull/1224.patch | patch -fsup 1 -d %PATCH_PREFIX% ) || ( set errorlevel= )

pytest -v -s -m indexed_gzip_test --niters 250          --pyargs indexed_gzip -k "not drop_handles"
pytest -v -s -m indexed_gzip_test --niters 250 --concat --pyargs indexed_gzip -k "not drop_handles"
