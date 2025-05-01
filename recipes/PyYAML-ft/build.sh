${PYTHON} -m pip install .                  \
    -vv                                     \
    --no-deps                               \
    --no-build-isolation                    \
    --global-option="--with-libyaml"        \
    --global-option="build_ext"             \
    --global-option="-I${PREFIX}/include"   \
    --global-option="-L${PREFIX}/lib"
