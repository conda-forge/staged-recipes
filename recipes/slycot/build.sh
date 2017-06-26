# NOTE : These flags are set due to this numpy.distutils bug
# https://github.com/numpy/numpy/issues/2411
if [[ `uname` == 'Darwin' ]]; then
    export LDFLAGS="${LDFLAGS} -undefined dynamic_lookup -bundle -Wl,-search_paths_first"
else
    # NOTE : Getting this error on Linux CircleCI:
    # https://stackoverflow.com/questions/11116399/crt1-o-in-function-start-undefined-reference-to-main-in-linux
    # so added -nostartfiles
    export LDFLAGS="${LDFLAGS} -nostartfiles -shared"
fi
$PYTHON setup.py install
