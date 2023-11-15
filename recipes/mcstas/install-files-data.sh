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
test -d "${SRCDIR}"
test -f "${SRCDIR}/CMakeLists.txt"
test -d "${SRCDATADIR}"
test -f "${SRCDATADIR}/Al.laz"
test -n "${PKG_VERSION}"
test -n "${PYTHON}"

mkdir -p "${DESTDATADIR}"

NADDED=0

function check_no_forbidden_chars() {
    #Check for forbidden chars in hopefully sufficiently
    #portable way (tested with zsh and bash4).
    case "$1" in
        .*) return 1;;
        *" "*) return 1;;
        *"~"*) return 1;;
        *\#*) return 1;;
        *) return 0;;
    esac
}

function do_copy_file() {
    forig="$1"
    destdir="$2"
    bn=$(basename "${forig}")
    test -f "${forig}"
    if [ -h "${forig}" ]; then
        return 1
    fi
    check_no_forbidden_chars || return 1
    mkdir -p "${destdir}"
    #Transfer file via cat, to discard any weird permission bits:
    cat "${forig}" > "${destdir}/${bn}"
    ((++NADDED))
}

for f1 in "${SRCDATADIR}"/* ; do
    #Support a single layer of sub-directories only:
    if [ -d  "${f1}" ]; then
        subdirname=$(basename "${f1}")
        for f2 in "${f1}"/* ; do
            if [ -d "${f2}" ]; then
                echo "Too many nested subdirs in src data dir!!"
                false
            fi
            do_copy_file "${f2}" "${DESTDATADIR}/${subdirname}"
        done
    else
        do_copy_file "${f1}" "${DESTDATADIR}"
    fi
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
