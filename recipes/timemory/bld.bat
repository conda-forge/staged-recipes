setlocal EnableDelayedExpansion

python -m pip install . --no-deps --ignore-installed -vvv

if errorlevel 1 exit 1
