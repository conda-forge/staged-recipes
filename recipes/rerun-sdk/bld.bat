@echo on

set "PYO3_PYTHON=%PYTHON%"

%PYTHON% -m pip install --ignore-installed --no-deps -vv .
if errorlevel 1 exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1