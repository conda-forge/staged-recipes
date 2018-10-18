mv setup_modified.py setup.py

export ADDITIONAL_INCLUDE_PATHS=$PREFIX/include/libjxr/image:$PREFIX/include/libjxr/common:$PREFIX/include/libjxr/glue:$PREFIX/include/openjpeg-2.3

export JPEG12_INCLUDE=$PREFIX/include/jpeg12

export CPATH=$ADDITIONAL_INCLUDE_PATHS:$CPATH
export LDSHARED=$CC

$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
