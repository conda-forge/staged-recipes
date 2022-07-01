#!/bin/bash
SNAP_PKG='esa-snap_sentinel_unix_*.sh'

chmod 755 $PREFIX/snap-src/$SNAP_PKG

$PREFIX/snap-src/$SNAP_PKG -q -dir $PREFIX/snap &>> $PREFIX/.messages.txt
ln -fs $PREFIX/snap/bin/snap ${PREFIX}/bin/snap

rm -fr $PREFIX/snap-src/$SNAP_PKG

SNAP_HOME="$PREFIX/snap/.snap"
SNAP_PATH="$PREFIX/snap/"
SNAP_USER="${PREFIX}/snap/.snap"


# # create dir for needed folders
# mkdir -p $SNAP_HOME
# mkdir -p $SNAP_USER/snap-python/snappy
# mkdir -p ${SNAP_HOME}/../snap-src
# mkdir -p ${PREFIX}/bin




# # Install and update snap
# SNAP_PKG='esa-snap_sentinel_unix_*.sh'

# chmod 755 ${SNAP_PATH}/../snap-src/$SNAP_PKG

# ${SNAP_HOME}/../snap-src/$SNAP_PKG -q -dir $SNAP_HOME &>> ${PREFIX}/.messages.txt

# # cleanup installer
# rm -fr ${SNAP_HOME}/../snap-src/$SNAP_PKG

echo "SNAP_HOME is $SNAP_HOME" &>> $PREFIX/.messages.txt
echo "updating snap.userdir in  $PREFIX/snap/etc/snap.properties " &>> $PREFIX/.messages.txt
sed -i "s!#snap.userdir=!snap.userdir=$SNAP_HOME!g" $PREFIX/snap/etc/snap.properties 

echo "updating default_userdir in $PREFIX/snap/etc/snap.conf " &>> $PREFIX/.messages.txt
sed -i "s!\${HOME}!$PREFIX/snap/!g" $PREFIX/snap/etc/snap.conf &>> $PREFIX/.messages.txt

echo "updating snap modules" &>> $PREFIX/.messages.txt
$PREFIX/snap/bin/snap --nosplash --nogui --modules --update-all 2>&1 | while read -r line; do
    echo "$line"
    [ "$line" = "updates=0" ] && sleep 2 && pkill -TERM -f "snap/jre/bin/java"
done

echo "update concluded" &>> $PREFIX/.messages.txt

echo "Give read/write permissions for snap home folder"  &>> $PREFIX/.messages.txt
chmod -R 777 $SNAP_HOME &>> $PREFIX/.messages.txt

echo "setting python_version variable" &>> $PREFIX/.messages.txt
python_version=$( $PREFIX/bin/python -c 'import sys; print("{}.{}".format(sys.version_info[0], sys.version_info[1]))' )
echo "python_version is $python_version " &>> $PREFIX/.messages.txt


# retrieving jpy wheel to copy in $SNAP_HOME/snap-python/snappy directory
jpy_file=$(find  $PREFIX/snap-src/jpy -name "jpy-*-cp*-cp*-linux_x86_64.whl")
if [ -z "$jpy_file" ]
then
	echo "Jpy has not been installed correctly" &>> $PREFIX/.messages.txt
	exit 1
fi

jpy_filename=$(basename $jpy_file)

# check if $SNAP_HOME/snap-python/snappy directory exists, if not create it
if [ -d "$SNAP_HOME/snap-python/snappy" ]
then
	echo "$SNAP_HOME/snap-python/snappy directory exists"  &>> $PREFIX/.messages.txt
else
	echo "creating $SNAP_HOME/snap-python/snappy directory"  &>> $PREFIX/.messages.txt
	mkdir -p $SNAP_HOME/snap-python/snappy &>> $PREFIX/.messages.txt
fi

# copying jpy wheel to snappy folder
echo "Copying $jpy_file to $SNAP_HOME/snap-python/snappy/$jpy_filename" &>> $PREFIX/.messages.txt
echo "running: cp ${jpy_file} $SNAP_HOME/snap-python/snappy/$jpy_filename" &>> $PREFIX/.messages.txt
cp ${jpy_file} $SNAP_HOME/snap-python/snappy/$jpy_filename &>> $PREFIX/.messages.txt

echo "running snappy-conf: $PREFIX/snap/bin/snappy-conf $PREFIX/bin/python" &>> $PREFIX/.messages.txt

$PREFIX/snap/bin/snappy-conf $PREFIX/bin/python$python_version | while read -r line; do
    echo "$line"
    [ "$line" = "or copy the 'snappy' module into your Python's 'site-packages' directory." ] && sleep 2 && pkill -TERM -f "nbexec"
done


echo " copying snappy folder to site-packages to make it importable: cp -r $SNAP_HOME/snap-python/snappy $PREFIX/lib/python${python_version}/site-packages"
# cp -r $SNAP_HOME/snap-python/snappy/* $PREFIX/lib/python${python_version}/site-packages/esasnappy &>> $PREFIX/.messages.txt
ln -fs ${SNAP_USER}/snap-python/snappy ${PREFIX}/lib/python${python_version}/site-packages/esasnappy &>> ${PREFIX}/.messages.txt


echo "Setting execution permissions to gdal.jar" &>> $PREFIX/.messages.txt
chmod +x $SNAP_HOME/auxdata/gdal/gdal-*/java/gdal.jar &>> $PREFIX/.messages.txt

## Jdk from package requirements
#echo "Setting the default version of java to 1.7" &>> $PREFIX/.messages.txt
#JAVA_PATH=/opt/anaconda/pkgs/java-1.7.0-openjdk-cos6-x86_64-1.7.0.131-h06d78d4_0/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.131.x86_64/jre/bin/java
#echo "Java binary: $JAVA_PATH" &>> $PREFIX/.messages.txt
## update java alternatives
#alternatives --install /usr/bin/java java $JAVA_PATH 1 &>> $PREFIX/.messages.txt
## choose the java version you just installed 
#alternatives --set java $JAVA_PATH &>> $PREFIX/.messages.txt


# adding snap binaries to  PATH
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d

mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

echo "#!/bin/bash 
export PATH=$PREFIX/snap/bin:\$PATH" >> $ACTIVATE_DIR/env_vars.sh

echo "#!/bin/bash
PATH=\$(echo \$PATH | sed -e 's@$PREFIX/snap/bin:@@g')
export PATH=\$PATH"  >>  $DEACTIVATE_DIR/env_vars.sh
