set PYYAML_FORCE_CYTHON=1
set PYYAML_FORCE_LIBYAML=1

%PYTHON% -m pip install . ^
    -vv ^
    --no-deps ^
    --no-build-isolation
