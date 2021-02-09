
export EUPSPKG_NJOBS=2

###############################################################################
# now build eigen and symlink it to where it can be found by default
# this is for scarlet
echo "
Building eigen and making the symlinks..."
stackvana-build eigen
if [[ `uname -s` == "Darwin" ]]; then
    eigendir=$(compgen -G "${EUPS_PATH}/DarwinX86/eigen/3.3.7.lsst2*")
else
    eigendir=$(compgen -G "${EUPS_PATH}/Linux64/eigen/3.3.7.lsst2*")
fi
ln -s ${eigendir}/include/eigen3/Eigen ${PREFIX}/include/Eigen

stackvana-build lsst_distrib

# get the (de)activate scripts
for CHANGE in "activate" "deactivate"; do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
