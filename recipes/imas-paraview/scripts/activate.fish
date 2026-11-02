set -l py "$CONDA_PREFIX/bin/python"
set -l helper "$CONDA_PREFIX/etc/conda/imas-paraview-pvpath.py"
if test -f "$helper"; and test -x "$py"
    $py $helper contains >/dev/null 2>/dev/null
    if test $status -eq 1
        set -l new ($py $helper add)
        if test $status -eq 0
            set -l key ($py $helper key)
            if test $status -eq 0
                set -gx PV_PLUGIN_PATH "$new"
                set -gx $key 1
            end
        end
    end
end
