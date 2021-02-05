#!/bin/bash
if [[ ! ${LSST_HOME} ]]
then
    echo "LSST_HOME is not set!"
    exit 1
fi

if [[ ! ${STACKVANA_ACTIVATED} ]]
then
    echo "STACKVANA_ACTIVATED is not set!"
    exit 1
fi

echo "
environment:"
env | sort

echo "
eups runs:"
{
    eups -h
} || {
    exit 1
}

echo "
eups list:"
{
    eups list
} || {
    exit 1
}


# this should work
echo "attempting to build 'pex_exceptions' ..."
stackvana-build pex_exceptions
echo " "

echo -n "setting up 'pex_exceptions' ... "
val=`setup -j pex_exceptions 2>&1`
if [[ ! ${val} ]]; then
    echo "worked!"
else
    echo "failed!"
    exit 1
fi

# try an import
setup pex_exceptions
python -c "import lsst.pex.exceptions"
