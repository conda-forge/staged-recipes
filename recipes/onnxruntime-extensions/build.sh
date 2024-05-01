export CMAKE_ARGS="-DPython_EXECUTABLE=$PYTHON -DPYTHON3_EXECUTABLE=$PYTHON -DPYTHON3_LIBRARY=$PYTHON3_LIBRARY -DPYTHON3_INCLUDE_DIR=$PYTHON3_INCLUDE_DIR"

if [[ "$OSTYPE" == "darwin"* ]]; then
    #export CMAKE_ARGS="$CMAKE_ARGS -DOCOS_ENABLE_RE2_REGEX=OFF"
    export OSX_OPTIONS='--config-settings "ortx-user-option=no-opencv"'
else
    export OSX_OPTIONS=""
fi

$PYTHON -m pip install . -vv --no-deps --no-build-isolation $OSX_OPTIONS
