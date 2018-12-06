set -euf 

pushd src/python

sed -i "s|\.\./\.libs/libseccomp.a|$PREFIX/lib/libseccomp.a|" setup.py

export VERSION_RELEASE=$PKG_VERSION
export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"

$PYTHON -m pip install . --no-deps

popd
