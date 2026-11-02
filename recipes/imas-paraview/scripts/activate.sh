# IMAS-ParaView activation for bash/zsh (sourced by the environment manager).
_imas_py="$CONDA_PREFIX/bin/python"
_imas_helper="$CONDA_PREFIX/etc/conda/imas-paraview-pvpath.py"
if [ -f "$_imas_helper" ] && [ -x "$_imas_py" ]; then
    if "$_imas_py" "$_imas_helper" contains >/dev/null 2>&1; then
        :
    else
        _imas_new=$("$_imas_py" "$_imas_helper" add) &&
        _imas_key=$("$_imas_py" "$_imas_helper" key) && {
            export PV_PLUGIN_PATH="$_imas_new"
            export "$_imas_key=1"
        }
    fi
fi
unset _imas_py _imas_helper _imas_new _imas_key
