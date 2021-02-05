# clean out our stuff - no need to backup or restore
unset STACKVANA_ACTIVATED

# remove stackvana env changes
for var in LSST_HOME LSST_PYVER LSST_DM_TAG \
        PYTHONPATH \
        LD_LIBRARY_PATH DYLD_LIBRARY_PATH \
        LSST_LIBRARY_PATH \
        SCONSUTILS_USE_CONDA_COMPILERS \
        EUPS_PKGROOT; do
    stackvana_backup_and_append_envvar \
        deactivate \
        $var
done

unset -f stackvana_backup_and_append_envvar
