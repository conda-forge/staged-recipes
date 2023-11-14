#!/usr/bin/env bash

#Make sure we fail hard in case of trouble:
set -e
set -u
set -x

SRCDIR="$PWD/src"
SRCDATADIR="${SRCDIR}/mcstas-comps/data"
DESTDATADIR="${PREFIX}/share/mcstas/resources/data"
#A few (silent) sanity checks that variables are set and meaningful:
test -d "${PREFIX}"
test -d ${SRCDIR}
test -f ${SRCDIR}/CMakeLists.txt
test -d ${SRCDATADIR}
which cmake > /dev/null
test -n "${PKG_VERSION}"
test -n "${PYTHON}"

mkdir -p "${DESTDATADIR}"

NADDED=0

for forig in "${SRCDIR}/*"; do
    #ensure no directories or symlinks:
    test -f "${forig}"
    if [ -h "${forig}" ]; then false; fi
    bn=$(basename "${forig}")
    if [[ "${bn}" == *@( |~|\#)* ]]; then false; fi
    cp "${forig}" "${DESTDATADIR}/${bn}"
    chmod -x "${DESTDATADIR}/${bn}"
    chmod -w "${DESTDATADIR}/${bn}"
    chmod +r "${DESTDATADIR}/${bn}"
    ((++NADDED))
done
if [ $NADDED -eq 0 ]; then
    echo 'Did not add ANY data files in mcstas-data package!'
    false
fi
if [ $NADDED -gt 2000 ]; then
    echo 'Suspiciously high number of data files added in mcstas-data package!'
    false
fi

echo  "mcstas-data-${PKG_VERSION}" > "${DESTDATADIR}"/.mcstas-data-version-conda.txt
