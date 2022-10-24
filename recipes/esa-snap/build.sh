#/usr/bin/bash
#
#
#

# Set Fonts directory
# export JAVA_FONTS=$PREFIX/fonts

# create source dir and move install script to common name
mkdir -p $PREFIX/snap-src
SNAP_PKG=$PREFIX/snap-src/esa-snap_all_unix.sh
mv $SRC_DIR/esa-snap_all_unix_*.sh $SNAP_PKG

# install snap
chmod 755 $SNAP_PKG
$SNAP_PKG -q -J-DJAVA_FONTS=$PREFIX/fonts -dir $PREFIX/snap &>> $PREFIX/messages.txt

# remove snap
rm -fr $SNAP_PKG

# setup snap home/paths
SNAP_HOME="$PREFIX/snap/.snap"

echo "SNAP_HOME is $SNAP_HOME" &>> $PREFIX/messages.txt
echo "updating snap.userdir in  $PREFIX/snap/etc/snap.properties " &>> $PREFIX/messages.txt
sed -i "s!#snap.userdir=!snap.userdir=$SNAP_HOME!g" $PREFIX/snap/etc/snap.properties 

echo "updating default_userdir in $PREFIX/snap/etc/snap.conf " &>> $PREFIX/messages.txt
sed -i "s!\${HOME}!$PREFIX/snap/!g" $PREFIX/snap/etc/snap.conf &>> $PREFIX/messages.txt

### Update SNAP
echo "updating snap modules" &>> $PREFIX/.messages.txt
# Current workaround for "commands hang after they are actually executed":  https://senbox.atlassian.net/wiki/spaces/SNAP/pages/30539785/Update+SNAP+from+the+command+line
# /usr/local/snap/bin/snap --nosplash --nogui --modules --update-all
$PREFIX/snap/bin/snap --nosplash --nogui --modules --update-all 2>&1 | while read -r line; do
    echo "$line"
    [ "$line" = "updates=0" ] && sleep 2 && pkill -TERM -f "snap/jre/bin/java";
done; exit 0

echo "update concluded" &>> $PREFIX/.messages.txt

echo "Give read/write permissions for snap home folder"  &>> $PREFIX/messages.txt
chmod -R 777 $SNAP_HOME &>> $PREFIX/messages.txt

echo "setting python_version variable" &>> $PREFIX/messages.txt
python_version=$( $PREFIX/bin/python -c 'import sys; print("{}.{}".format(sys.version_info[0], sys.version_info[1]))' )
echo "python_version is $python_version " &>> $PREFIX/messages.txt

echo "setting max jvm mem to 40gb " &>> $PREFIX/messages.txt
echo -e "-Xmx40G" >> $SNAP_HOME/bin/gpt.vmoptions

mkdir -p $SNAP_HOME/system/var/log
cat $PREFIX/messages.txt >> $SNAP_HOME/system/var/log/messages.log

# adding snap binaries to PATH
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d

mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

echo "#!/bin/bash 
export PATH=$PREFIX/snap/bin:\$PATH" >> $ACTIVATE_DIR/env_vars.sh

echo "#!/bin/bash
PATH=\$(echo \$PATH | sed -e 's@$PREFIX/snap/bin:@@g')
export PATH=\$PATH"  >>  $DEACTIVATE_DIR/env_vars.sh
