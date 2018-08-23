if [ $OSX_ARCH ]; then
export LDFLAGS=${LDFLAGS}" "-undefined" "dynamic_lookup
else
export LDFLAGS=${LDFLAGS}" "-shared
fi
$PYTHON setup.py install
