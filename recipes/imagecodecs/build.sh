mv setup_modified.py setup.py

export ADDITIONAL_INCLUDE_PATHS=$PREFIX/include/libjxr/image:$PREFIX/include/libjxr/common:$PREFIX/include/libjxr/glue:$PREFIX/include/openjpeg-2.3
echo $ADDITIONAL_INCLUDE_PATHS

export CPATH=$ADDITIONAL_INCLUDE_PATHS:$CPATH
echo $CPATH
export LDSHARED=$CC

find $PREFIX/include

$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
