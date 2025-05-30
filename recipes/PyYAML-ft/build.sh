export PYYAML_FORCE_CYTHON=1
export PYYAML_FORCE_LIBYAML=1

${PYTHON} -m pip install .                  \
    -vv                                     \
    --no-deps                               \
    --no-build-isolation
