set PYYAML_FORCE_CYTHON=1
set PYYAML_FORCE_LIBYAML=1
set CFLAGS="-I%LIBRARY_INC%"
set LDFLAGS="-L%LIBRARY_LIB%"

%PYTHON% -m pip install . ^
    -vv ^
    --no-deps ^
    --no-build-isolation
