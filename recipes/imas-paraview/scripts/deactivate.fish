set -l py "$CONDA_PREFIX/bin/python"
set -l helper "$CONDA_PREFIX/etc/conda/imas-paraview-pvpath.py"
if test -f "$helper"; and test -x "$py"
    $py $helper owned >/dev/null 2>/dev/null
    if test $status -eq 0
        set -l key ($py $helper key)
        or return
        set -l new ($py $helper remove)
        if test $status -eq 0
            if test -n "$new"
                set -gx PV_PLUGIN_PATH "$new"
            else
                set -e PV_PLUGIN_PATH
            end
            set -e $key
        end
    end
end
