#!/bin/bash

###############################################################################
# env control

LSST_HOME="${PREFIX}/lsst_home"
export EUPS_PKGROOT="https://eups.lsst.codes/stack/src"
export LSST_PYVER="3.8"

# tell eups where CURL is
CURL="${PREFIX}/bin/curl"
# disable curl progress meter unless running under a tty -- this is intended
# to reduce the amount of console output when running under CI
CURL_OPTS='-#'
if [[ ! -t 1 ]]; then
    CURL_OPTS='-sS'
fi

if [[ ${PKG_VERSION} == "0."* ]]; then
    patchv=$(echo $PKG_VERSION | cut -d. -f3)
    if [[ ${#patchv} == "1" ]]; then
      LSST_TAG="w_"$(echo $PKG_VERSION | cut -d. -f2)"_0"${patchv}
    else
      LSST_TAG="w_"$(echo $PKG_VERSION | cut -d. -f2)"_"${patchv}
    fi
else
    LSST_TAG="v"${PKG_VERSION//./_}
fi

###############################################################################
# functions
#
# create/update a *relative* symlink, in the basedir of the target. An existing
# file or directory will be *stomped on*.
#
n8l::ln_rel() {
    local link_target=${1?link target is required}
    local link_name=${2?link name is required}

    target_dir=$(dirname "$link_target")
    target_name=$(basename "$link_target")

    ( set -e
        cd "$target_dir"

        if [[ $(readlink "$target_name") != "$link_name" ]]; then
            # at least "ln (GNU coreutils) 8.25" will not change an abs symlink to be
            # rel, even with `-f`
            rm -rf "$link_name"
            ln -sf "$target_name" "$link_name"
        fi
    )
}


###############################################################################
# actual stuff

mkdir -p ${LSST_HOME}
pushd ${LSST_HOME}

# the install expects this symlink
n8l::ln_rel "${PREFIX}" current

# now the main script
echo "
LSST DM TAG: "${LSST_TAG}

# update $EUPS_DIR current symlink
n8l::ln_rel "${EUPS_DIR}" current

# update EUPS_PATH current symlink
n8l::ln_rel "${EUPS_PATH}" current

popd  # LSST_HOME

# we use a separate set of activate and deactivate scripts that get sourced
# by the main conda ones
# this allows other packages which depend on this one to use them as well

# copy the stackvana activate and deactivate scripts
# these are sourced by the conda ones of the same name if needed
cp ${RECIPE_DIR}/stackvana_deactivate.sh ${LSST_HOME}/stackvana_deactivate.sh

echo "
# ==================== added by build.sh in recipe build

export STACKVANA_BACKUP_LSST_HOME=\${LSST_HOME}
export LSST_HOME=\"\${CONDA_PREFIX}/lsst_home\"

export STACKVANA_BACKUP_LSST_DM_TAG=\${LSST_DM_TAG}
export LSST_DM_TAG=${LSST_TAG}

export STACKVANA_BACKUP_LSST_PYVER=\${LSST_PYVER}
export LSST_PYVER=${LSST_PYVER}

# ==================== end of added stuff

" > ${LSST_HOME}/stackvana_activate.sh
cat ${RECIPE_DIR}/stackvana_activate.sh >> ${LSST_HOME}/stackvana_activate.sh

# copy the conda ones
for CHANGE in "activate" "deactivate"; do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

cp ${RECIPE_DIR}/stackvana-build ${PREFIX}/bin/stackvana-build
chmod u+x ${PREFIX}/bin/stackvana-build

###############################################################################
# now install sconsUtils
# this brings most of the basic build tools into the env and lets us patch it

echo "
Building sconsUtils..."
eups distrib install -v -t ${LSST_TAG} sconsUtils

echo "Patching sconsUtils for debugging..."
if [[ `uname -s` == "Darwin" ]]; then
    sconsdir=$(compgen -G "${EUPS_PATH}/DarwinX86/sconsUtils/*/python/lsst/sconsUtils")
else
    sconsdir=$(compgen -G "${EUPS_PATH}/Linux64/sconsUtils/*/python/lsst/sconsUtils")
fi
pushd ${sconsdir}
patch tests.py ${RECIPE_DIR}/0001-print-test-env-sconsUtils.patch
if [[ "$?" != "0" ]]; then
    exit 1
fi
patch tests.py ${RECIPE_DIR}/0002-ignore-binsrc.patch
if [[ "$?" != "0" ]]; then
    exit 1
fi
popd

###############################################################################
# now finalize the build

# # now fix up the python paths
# we set the python #! line by hand so that we get the right thing coming out
# in conda build for large prefixes this always has /usr/bin/env python
echo "
Fixing the python scripts with shebangtron..."
export SHTRON_PYTHON=${PYTHON}
curl -sSL https://raw.githubusercontent.com/lsst/shebangtron/master/shebangtron | ${PYTHON}
echo " "

# clean out .pyc files made by eups installs
# these cause problems later for a reason I don't understand
# conda remakes them IIUIC
for dr in ${LSST_HOME} ${PREFIX}/lib/python${LSST_PYVER}/site-packages; do
    pushd $dr
    if [[ `uname -s` == "Darwin" ]]; then
        find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
    else
        find . -regex '^.*\(__pycache__\|\.py[co]\)$' -delete
    fi
    popd
done

# clean out any documentation
# this bloats the packages, is usually a ton of files, and is not needed
compgen -G "${EUPS_PATH}/*/*/*/tests/.tests/*" | xargs rm -rf
compgen -G "${EUPS_PATH}/*/*/*/tests/*" | xargs rm -rf
compgen -G "${EUPS_PATH}/*/*/*/bin.src/*" | xargs rm -rf
compgen -G "${EUPS_PATH}/*/*/*/doc/html/*" | xargs rm -rf
compgen -G "${EUPS_PATH}/*/*/*/doc/xml/*" | xargs rm -rf
compgen -G "${EUPS_PATH}/*/*/*/share/doc/*" | xargs rm -rf
compgen -G "${EUPS_PATH}/*/*/*/share/man/*" | xargs rm -rf

# maybe this?
echo "=================== eups list ==================="
eups list -s --topological -D --raw 2>/dev/null
echo "================================================="

# remove the global tags file since it tends to leak across envs
rm -f ${EUPS_DIR}/ups_db/global.tags
