# we have to check if things have not already been activated
if [[ ! ${STACKVANA_ACTIVATED} ]]; then
    source ${CONDA_PREFIX}/lsst_home/stackvana_activate.sh
fi
