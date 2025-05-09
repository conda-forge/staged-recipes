export PYYAML_FORCE_CYTHON=1
export PYYAML_FORCE_LIBYAML=1
export CFLAGS="-I%LIBRARY_INC%"
export LDFLAGS="-L%LIBRARY_LIB%"

${PYTHON} -m pip install .                  \
    -vv                                     \
    --no-deps                               \
    --no-build-isolation
