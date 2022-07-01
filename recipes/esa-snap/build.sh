SNAP_PKG='esa-snap_sentinel_unix_8_0.sh'

mkdir -p $PREFIX/snap-src

# cp $SRC_DIR/$SNAP_PKG $PREFIX/snap-src/
cp -r $SRC_DIR/* $PREFIX/snap-src/

export JAVA_HOME=${PREFIX}
export JAVA_LD_LIBRARY_PATH=${JAVA_HOME}/jre/lib/amd64/server

# pip install --upgrade pip wheel
(cd $PREFIX/snap-src/jpy && python setup.py bdist_wheel)
# hack because ./snappy-conf will create this dir but also needs *.whl files...
# mkdir -p /root/.snap/snap-python/snappy
# cp $PREFIX/snap-src/jpy/dist/*.whl "/root/.snap/snap-python/snappy"

cd $PREFIX