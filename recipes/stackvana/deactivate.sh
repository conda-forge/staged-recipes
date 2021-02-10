if [[ ${STACKVANA_ACTIVATED} ]]; then
    {
        unsetup lsst_distrib >/dev/null 2>&1
    } || {
        echo "DM stack could not be deactivated!"
    }
    source ${CONDA_PREFIX}/lsst_home/stackvana_deactivate.sh
fi
