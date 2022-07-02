SNAP_PKG='esa-snap_sentinel_unix_8_0.sh'

mkdir -p $PREFIX/snap-src

# cp $SRC_DIR/$SNAP_PKG $PREFIX/snap-src/
cp -r $SRC_DIR/* $PREFIX/snap-src/

SNAP_PKG='esa-snap_sentinel_unix_*.sh'

chmod 755 $PREFIX/snap-src/$SNAP_PKG

$PREFIX/snap-src/$SNAP_PKG -q -dir $PREFIX/snap &>> $PREFIX/.messages.txt
ln -fs $PREFIX/snap/bin/snap ${PREFIX}/bin/snap

rm -fr $PREFIX/snap-src/$SNAP_PKG

export JDK_HOME=${PREFIX}/snap/jre/
export JAVA_HOME=$JDK_HOME
export JAVA_LD_LIBRARY_PATH=${JAVA_HOME}/jre/lib/amd64/server
export LD_LIBRARY_PATH=$JDK_HOME/jre/lib/server:$LD_LIBRARY_PATH

# pip install --upgrade pip wheel
(cd $PREFIX/snap-src/jpy && python setup.py --maven build)
# hack because ./snappy-conf will create this dir but also needs *.whl files...
# mkdir -p /root/.snap/snap-python/snappy
# cp $PREFIX/snap-src/jpy/dist/*.whl "/root/.snap/snap-python/snappy"

cd $PREFIX