export SETUPTOOLS_SCM_PRETEND_VERSION=${PKG_VERSION}
export CMAKE_GENERATOR=Ninja

$PYTHON -m pip install file:./gen/python --no-deps --no-build-isolation -vv
$PYTHON -m pip install file:./third_party/skymarshal --no-deps --no-build-isolation -vv
$PYTHON -m pip install . --no-deps --no-build-isolation -vv

# Remove bundled third party C++ headers
rm -rf $PREFIX/include/fmt
rm -rf $PREFIX/include/lcmtypes
rm -rf $PREFIX/include/symengine

# Remove unrelated Python packages that are packaged accidentally
rm -rf $SP_DIR/test
rm -rf $SP_DIR/tests
