set -e

# showing gfortran version for debugging
gfortran --version

# echoing out the PATH to see what is automatically avilable
echo ''
echo $PATH

echo ''
echo '======================================================================'
echo ''

# echoing out some additional information to try and track down missing libs
if [[ $(uname) == Darwin ]]; then
    echo $DYLD_FALLBACK_LIBRARY_PATH
elif [[ $(uname) == Linux ]]; then
    echo $LD_LIBRARY_PATH
fi

echo ''
echo ''
echo '======================================================================'
echo ''
# echo out some homebrew stuff, since I think I am actually using OSX's version of gfortran
if [[ $(uname) == Darwin ]]; then
    brew ls --verbose gcc
    echo ''
    echo '======================================================================'
    echo ''
    brew ls --verbose gfortran
fi

#
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
$PYTHON ./bin/build_model all STATIC_FLAG=-static
