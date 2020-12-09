echo "****************************"
echo "PYTHON ${PY_VER} BUILD STARTED"
echo "****************************"

set -x

# Remove old Python build files, if they're present
if [ -d "build/python" ]; then
    rm -rf build/python
    rm -rf build/temp-py
    rm interfaces/cython/setup.py
    rm -rf interfaces/cython/build
    rm -rf interfaces/cython/dist
    rm -rf interfaces/cython/Cantera.egg-info
fi

test -f cantera.conf

scons build python_package='y' python_cmd="${PYTHON}"

echo "****************************"
echo "PYTHON ${PY_VER} BUILD COMPLETED SUCCESSFULLY"
echo "****************************"

cd interfaces/cython
$PYTHON setup.py build --build-lib=../../build/python install --single-version-externally-managed --record record.txt

if [[ "$target_platform" == osx-* ]]; then
   VERSION=$(echo $PKG_VERSION | cut -db -f1)
   file_to_fix=$(find $SP_DIR -name "_cantera*.so" | head -n 1)
   ${OTOOL:-otool} -L $file_to_fix
   ${INSTALL_NAME_TOOL:-install_name_tool} -change build/lib/libcantera.${VERSION}.dylib "@rpath/libcantera.${VERSION}.dylib" $file_to_fix
fi
