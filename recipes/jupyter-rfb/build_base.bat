@ECHO ON
del pyproject.toml
%PYTHON% -m pip install --no-deps -vv --install-option="--skip-npm" . || exit 1
