# without this workaround, labbench source files were not found in a brew+mambaforge environment
mkdir .git
mkdir src
mv labbench src/labbench

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
