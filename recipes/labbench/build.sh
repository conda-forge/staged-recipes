# without this workaround, all labbench source files are missing
mkdir .git

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
