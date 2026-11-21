cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1
%PYTHON% -m pip install . --no-deps --no-build-isolation -vv
if errorlevel 1 exit 1