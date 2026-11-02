# Remove only the path that this environment's activation inserted.
_imas_py="$CONDA_PREFIX/bin/python"
_imas_helper="$CONDA_PREFIX/etc/conda/imas-paraview-pvpath.py"
if [ -f "$_imas_helper" ] && [ -x "$_imas_py" ]; then
    if "$_imas_py" "$_imas_helper" owned >/dev/null 2>&1; then
        _imas_new=$("$_imas_py" "$_imas_helper" remove) &&
        _imas_key=$("$_imas_py" "$_imas_helper" key) && {
            if [ -n "$_imas_new" ]; then
                export PV_PLUGIN_PATH="$_imas_new"
            else
                unset PV_PLUGIN_PATH
            fi
            unset "$_imas_key"
        }
    fi
fi
unset _imas_py _imas_helper _imas_key _imas_new
