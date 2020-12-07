echo "****************************"
echo "DEVEL LIBRARY INSTALL STARTED"
echo "****************************"

set -e
rm -f cantera.conf

cp "${RECIPE_DIR}/cantera_base.conf" cantera.conf

echo "prefix = '${PREFIX}'" >> cantera.conf
echo "boost_inc_dir = '${PREFIX}/include'" >> cantera.conf

if [[ "${OSX_ARCH}" == "" ]]; then
    echo "CC = '${CC}'" >> cantera.conf
    echo "CXX = '${CXX}'" >> cantera.conf
else
    echo "CC = '${CLANG}'" >> cantera.conf
    echo "CXX = '${CLANGXX}'" >> cantera.conf
    echo "cc_flags = '-isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}'" >> cantera.conf
fi

scons install
set +e

echo "****************************"
echo "DEVEL LIBRARY INSTALL COMPLETED SUCCESSFULLY"
echo "****************************"
