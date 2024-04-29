PYTHON3_LIBRARY=$($PYTHON -c 'import sysconfig; print(sysconfig.get_config_var("LIBDIR"))')/$($PYTHON -c 'import sysconfig; print(sysconfig.get_config_var("LDLIBRARY"))')
PYTHON3_INCLUDE_DIR=$($PYTHON -c 'import sysconfig; print(sysconfig.get_path("include"))')

export CMAKE_ARGS="-DPython_EXECUTABLE=$PYTHON -DPYTHON3_EXECUTABLE=$PYTHON -DPYTHON3_LIBRARY=$PYTHON3_LIBRARY -DPYTHON3_INCLUDE_DIR=$PYTHON3_INCLUDE_DIR"
echo "CMAKE_ARGS is $CMAKE_ARGS"
$PYTHON -m pip install . -vv --no-deps --no-build-isolation --config-settings "ortx-user-option=no-opencv"