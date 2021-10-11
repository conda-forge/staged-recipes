#!/bin/bash
set -ex
echo ==========   Welcome to build-server.sh  ==============
echo ================   ENVIRONMENT VARS  ==================
echo =============    for debugging purposes   =============
printenv | sort

echo ===================  Conda Envs  ====================
conda env list
conda list
## for debugging of dependency problems:
conda list --prefix $PREFIX
conda list --prefix $BUILD_PREFIX

echo ============================================================
echo ================   THIS IS AN ALPHA VERSION  ===============
echo ========   There is lot of debugging-code in here  =========
echo ============================================================
echo ============================================================



# CMAKE_INCLUDE_PATH
# -DCMAKE_INSTALL_PREFIX=$PREFIX
# -DCMAKE_INSTALL_LIBDIR=lib
# -DBUILD_SHARED_LIBS=ON

echo make the default rserver.conf be loaded from \$PREFIX/etc/rstudio/rserver.conf
## this needs to be done dynamically based on $PREFIX, hence it cannot be a patch.
cat src/cpp/core/system/Xdg.cpp | sed -e "s|\"/etc\"|\"${PREFIX}/etc\"|" > _XDG_tmp.cpp
mv _XDG_tmp.cpp src/cpp/core/system/Xdg.cpp

export RSTUDIO_TARGET=Server

export PAM_FROM_CDT=false

# install
# if(NOT EXISTS "${RSTUDIO_DEPENDENCIES_DIR}/common/dictionaries")
export RSTUDIO_DEPENDENCIES_DIR=$PREFIX/share/
mkdir -p ${RSTUDIO_DEPENDENCIES_DIR}/common/dictionaries
# mkdir -p ${RSTUDIO_DEPENDENCIES_DIR}/common/mathjax-27
# TODO can we force Rstudio to use $PREFIX/lib/mathjax always?
cp -r $PREFIX/lib/mathjax ${RSTUDIO_DEPENDENCIES_DIR}/common/mathjax-27
mkdir -p ${RSTUDIO_DEPENDENCIES_DIR}/common/pandoc/2.11.2
# pushd dependencies/common
#   ./install-gwt
#   ./install-dictionaries
#   ./install-mathjax
# # ./install-boost
# # ./install-pandoc
# # ./install-libclang
#   ./install-packages
# popd

# make the panmirror npm-package as in the end of dependencies/common/install-npm-dependencies
( cd src/gwt/panmirror/src/editor && \
yarn config set ignore-engines true && \
yarn install )


mkdir -p dependencies/common/node/10.19.0/bin/
ln -fs $BUILD_PREFIX/bin/node dependencies/common/node/10.19.0/bin/
# which node|xargs ln -s

# Problem with installing soci_postgresql into host env, so install it in build and copy it here:
cp $BUILD_PREFIX/lib/libsoci_postgresql* $PREFIX/lib/


# r-base=3.6.1 -> curl -> openssl[version='1.0.*|>=1.0.2o,<1.0.3a|>=1.0.2p,<1.0.3a|>=1.0.2m,<1.0.3a|>=1.1.1a,<1.1.2a|>=1.1.1d,<1.1.2a|>=1.1.1h,<1.1.2a|>=1.1.1g,<1.1.2a|>=1.1.1f,<1.1.2a|>=1.1.1c,<1.1.2a|>=1.1.1b,<1.1.2a|>=1.0.2n,<1.0.3a']

# export xx=/home/conda/feedstock_root/build_artifacts/debug_1611506092555/_build_env/x86_64-conda_cos6-linux-gnu/sysroot/usr
# PAM_LIB=$CONDA_BUILD_SYSROOT/../../x86_64-conda_cos6-linux-gnu/sysroot
# echo $PAM_LIB

declare -a _CMAKE_EXTRA_CONFIG
LIBRT=$(find ${PREFIX} -name "librt.so")
LIBPTHREAD=$(find ${PREFIX} -name "libpthread.so")
LIBUTIL=$(find ${PREFIX} -name "libutil.so")
_CMAKE_EXTRA_CONFIG+=(-DPTHREAD_LIBRARIES=${LIBPTHREAD})
_CMAKE_EXTRA_CONFIG+=(-DUTIL_LIBRARIES=${LIBUTIL})
_CMAKE_EXTRA_CONFIG+=(-DRT_LIBRARIES=${LIBRT})
# May only be necessary for server?
if [[ $PAM_FROM_CDT == true ]] ; then
    PAM_INCLUDE_DIR=$(dirname `find ${PREFIX} -name security -type d | grep include/security | head -1`)
    PAM_INCLUDE_DIR=/usr/include
fi
export CPPFLAGS="${CPPFLAGS} -Wl,-rpath-link,${PREFIX}/lib -I$BUILD_PREFIX/include"
export CXXFLAGS="${CXXFLAGS} -Wl,-rpath-link,${PREFIX}/lib -I$BUILD_PREFIX/include"
# export CXXFLAGS="${CXXFLAGS} -Wl,-rpath-link,${PREFIX}/lib -I$PAM_INCLUDE_DIR -I$BUILD_PREFIX/include"
export CFLAGS="${CFLAGS} -Wl,-rpath-link,${PREFIX}/lib"

if [[ x${RSTUDIO_TARGET} == xServer ]]; then

MAIN_SYSROOT_DIR=$(dirname ${PREFIX}/${BUILD}/sysroot/usr)
LIBDL=$(find ${PREFIX} -name "libdl.so")

if [[ $PAM_FROM_CDT == true ]] ; then
    OTHER_SYSROOT_DIR=$(dirname ${PAM_INCLUDE_DIR})
    LIBPAM=$(find ${PREFIX} -name "libpam.so")
    LIBAUDIT=$(find ${PREFIX} -name "libaudit.so.1")
    ## currently pam is under x86_64-conda_cos6-linux-gnu and not unter BUILD=x86_64-conda-linux-gnu
    # _CMAKE_EXTRA_CONFIG+=(-DPAM_INCLUDE_DIR=${BUILD_PREFIX}/${BUILD}/sysroot/usr/include)
    _CMAKE_EXTRA_CONFIG+=(-DPAM_INCLUDE_DIR=${PAM_INCLUDE_DIR})
    _CMAKE_EXTRA_CONFIG+=(-DPAM_INCLUDE_DIRS=${PAM_INCLUDE_DIR})
    _CMAKE_EXTRA_CONFIG+=(-DCMAKE_PREFIX_PATH=${PREFIX}\;${BUILD_PREFIX}\;${MAIN_SYSROOT_DIR}\;${OTHER_SYSROOT_DIR})
    _CMAKE_EXTRA_CONFIG+=(-DCMAKE_SYSTEM_INCLUDE_PATH=${PREFIX}/include\;${BUILD_PREFIX}/include\;${MAIN_SYSROOT_DIR}/include\;${OTHER_SYSROOT_DIR}/include)
    _CMAKE_EXTRA_CONFIG+=(-DPAM_LIBRARY="${LIBPAM};${LIBAUDIT}")
else
    _CMAKE_EXTRA_CONFIG+=(-DPAM_INCLUDE_DIRS=/usr/include)
    _CMAKE_EXTRA_CONFIG+=(-DPAM_INCLUDE_DIR=/usr/include)
    _CMAKE_EXTRA_CONFIG+=(-DCMAKE_CXX_FLAGS="-Wl,-rpath-link,${PREFIX}/lib,-rpath-link,/usr/lib64,-rpath-link,/lib64 -I$BUILD_PREFIX/include -I/usr/include")
    _CMAKE_EXTRA_CONFIG+=(-DCMAKE_PREFIX_PATH=${PREFIX}\;${BUILD_PREFIX}\;${MAIN_SYSROOT_DIR})
    _CMAKE_EXTRA_CONFIG+=(-DCMAKE_SYSTEM_INCLUDE_PATH=${PREFIX}/include\;${BUILD_PREFIX}/include\;${MAIN_SYSROOT_DIR}/include\;/usr/include)
fi
_CMAKE_EXTRA_CONFIG+=(-DSOCI_INCLUDE_BUILD_DIR=${BUILD_PREFIX}/include)
_CMAKE_EXTRA_CONFIG+=(-DDL_LIBRARIES=${LIBDL})
fi

printenv
echo "${_CMAKE_EXTRA_CONFIG[@]}"

    # -DCMAKE_LIBRARY_PATH=$PAM_LIB/usr/lib64 \
    # -DCMAKE_PREFIX_PATH=$BUILD_PREFIX \
    # -DCMAKE_PREFIX_PATH=$PAM_LIB/usr\;$BUILD_PREFIX \
cmake . -L -DRSTUDIO_TARGET=Server -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release \
    -DRSTUDIO_PACKAGE_BUILD=1 -DBUILD_SHARED_LIBS=ON -DRSTUDIO_DEPENDENCIES_DIR=$RSTUDIO_DEPENDENCIES_DIR \
    -DBOOST_ROOT="${PREFIX}"                \
    -DBOOST_VERSION=1.69.0                  \
    -DLIBR_HOME="${PREFIX}"/lib/R           \
    "${_CMAKE_EXTRA_CONFIG[@]}"             \
    -DRSTUDIO_CRASHPAD_ENABLED=0 -DRSTUDIO_UNIT_TESTS_DISABLED=1 \
    -DSOCI_CORE_LIB=$PREFIX/lib/libsoci_core.so \
    -DSOCI_POSTGRESQL_LIB=$PREFIX/lib/libsoci_postgresql.so -DSOCI_SQLITE_LIB=$PREFIX/lib/libsoci_sqlite3.so
    # -DSOCI_POSTGRESQL_LIB=$BUILD_PREFIX/lib/libsoci_postgresql.so -DSOCI_SQLITE_LIB=$PREFIX/lib/libsoci_sqlite3.so
    # -DSOCI_LIBRARY_DIR=$PREFIX/lib/ 

#cmake . -DRSTUDIO_TARGET=Server  -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release -DRSTUDIO_PACKAGE_BUILD=1 -DBUILD_SHARED_LIBS=ON
# CMAKE_INSTALL_PREFIX

# mv /home/conda/feedstock_root/build_artifacts/debug_1611506092555/work/src/cpp/core/DatabaseTests.cpp{,.mv}
# touch /home/conda/feedstock_root/build_artifacts/debug_1611506092555/work/src/cpp/core/DatabaseTests.cpp
# cannot compile this because of issues with soci-header files ?!? But who needs tests anyway...
# echo > src/cpp/core/DatabaseTests.cpp

# ln -fs $BUILD_PREFIX/include/soci/postgresql $PREFIX/include/soci
# ln -fs $BUILD_PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/usr/include/security $BUILD_PREFIX/include
# ln -fs $BUILD_PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/usr/include/security $PREFIX/include
# export LD_LIBRARY_PATH=$BUILD_PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/lib64

## to do compilation only:
# make -f CMakeFiles/Makefile2 src/cpp/all

# CPU_COUNT=2
make -j "$CPU_COUNT" install


RSERVER_CONF=$PREFIX/etc/rstudio/rserver.conf
DB_CONF_FILE=$PREFIX/etc/rstudio/database.conf

mkdir -p `dirname $RSERVER_CONF`
mkdir -p `dirname $DB_CONF_FILE`
mkdir -p $PREFIX/var/{run,lock,log,lib}/rstudio-server
# conda build doesn't keep empty dirs
touch $PREFIX/var/{run,lock,log,lib}/rstudio-server/.mkdir

echo server-data-dir=$PREFIX/var/run/rstudio-server >> $RSERVER_CONF
echo database-config-file=$DB_CONF_FILE >> $RSERVER_CONF
echo server-pid-file=$PREFIX/var/run/rstudio-server.pid >> $RSERVER_CONF
# maybe set the user by default to the installation user ?!?
echo server-user=conda >> $RSERVER_CONF

echo directory=$PREFIX/var/lib/rstudio-server >> $DB_CONF_FILE
cat src/cpp/server/extras/conf/database.conf >> $DB_CONF_FILE

# mkdir -p ./var/{run,lock,log,lib}/rstudio-server
# chmod a+rws /var/{run,lock,log,lib}/rstudio-server

# make sure, that USER is set!!! else --auth-none 1 returns an empty user ?!?
# btw if it is run as root, --auth-none is 0 by default
# export USER=conda
# cd $PREFIX && rserver --server-data-dir $PWD/var/rstudio/ --server-user conda --auth-none 1
# USER=root XDG_CONFIG_DIRS=$CONDA_PREFIX/etc rserver


# cd ~/conda-rstudio/rstudio-feedstock
# conda activate smithy
# docker run --rm -itv $PWD:/work:ro -p 8787:8787 continuumio/miniconda3 bash
# cd /work/build_artifacts/
# conda create -n my -c file://$PWD/ -c conda-forge rstudio
# conda activate my
# USER=conda rserver


