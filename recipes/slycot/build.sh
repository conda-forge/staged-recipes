if [[ `uname` == 'Darwin' ]]; then
    export LDFLAGS=${LDFLAGS} -undefined dynamic_lookup -bundle -Wl,-search_paths_first"
else
    export LDFLAGS=${LDFLAGS} -shared"
fi
$PYTHON setup.py install --single-version-externally-managed --record record.txt
