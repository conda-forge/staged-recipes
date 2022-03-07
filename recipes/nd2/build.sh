PLATFORM=$(uname -s)

if [ "$PLATFORM" == "Linux" ]; then
    cp -a $SRC_DIR/src/sdk/$PLATFORM/x86_64/lib/. $PREFIX/lib
fi

$PYTHON -m pip install . -vv
