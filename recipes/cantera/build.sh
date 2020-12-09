set +x

echo "****************************"
echo "LIBRARY BUILD STARTED"
echo "****************************"

if [[ "$DIRTY" != "1" ]]; then
    scons clean
fi

rm -f cantera.conf

cp "${RECIPE_DIR}/cantera_base.conf" cantera.conf

echo "prefix = '${PREFIX}'" >> cantera.conf
echo "boost_inc_dir = '${PREFIX}/include'" >> cantera.conf
echo "extra_inc_dirs = '${PREFIX}/include:${PREFIX}/include/eigen3'" >> cantera.conf
echo "extra_lib_dirs = '${PREFIX}/lib'" >> cantera.conf

if [[ "${OSX_ARCH}" == "" ]]; then
    echo "CC = '${CC}'" >> cantera.conf
    echo "CXX = '${CXX}'" >> cantera.conf
else
    echo "CC = '${CLANG}'" >> cantera.conf
    echo "CXX = '${CLANGXX}'" >> cantera.conf
    echo "cc_flags = '-isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}'" >> cantera.conf
fi

if [[ "$target_platform" == osx-* ]]; then
    # scons on osx uses major.minor while on linux it is major only
    export APPLELINK_COMPATIBILITY_VERSION="$(echo ${PKG_VERSION} | cut -d. -f1)"
    echo "APPLELINK_COMPATIBILITY_VERSION='${APPLELINK_COMPATIBILITY_VERSION}'" >> cantera.conf
fi

set -xe

# FIXME REVERT BEFORE MERGING
if ! scons build -j${CPU_COUNT}; then
        cat config.log
        echo "BUILD FAILED"
        exit 1
fi

set +xe

echo "****************************"
echo "BUILD COMPLETED SUCCESSFULLY"
echo "****************************"
