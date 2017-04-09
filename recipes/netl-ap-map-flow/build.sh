set -e

# only doing static builds for linux, since OSX doesn't support it.
if [[ $(uname) == Linux ]]; then
  #STATIC_FLAG=-static
fi

export LDFLAGS="$LDFLAGS -lc -lm"
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
$PYTHON ./bin/build_model all STATIC_FLAG=$STATIC_FLAG
