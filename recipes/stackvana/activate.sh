# we have to check if things have not already been activated
if [[ ! ${STACKVANA_ACTIVATED} ]]; then
    source ${CONDA_PREFIX}/lsst_home/stackvana_activate.sh
fi

# call eups setup to get all galsim stuff in the path
{
    setup lsst_distrib >/dev/null 2>&1
} || {
    echo "DM stack could not be activated!"
}
