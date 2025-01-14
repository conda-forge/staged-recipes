cd %SRC_DIR%

if exist vendor(
    rmdir /s /q vendor
)

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
