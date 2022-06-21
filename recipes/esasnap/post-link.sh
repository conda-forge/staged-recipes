#!/bin/bash

SNAP_HOME="${PREFIX}/opt/snap"
SNAP_USER="${SNAP_HOME}/.snap"

# create dir for needed folders
mkdir -p $SNAP_HOME
mkdir -p $SNAP_USER/snap-python/snappy
mkdir -p ${SNAP_HOME}/../snap-src
mkdir -p ${PREFIX}/bin

# Install and update snap
SNAP_PKG='esa-snap_sentinel_unix_*.sh'

chmod 755 ${SNAP_HOME}/../snap-src/$SNAP_PKG

${SNAP_HOME}/../snap-src/$SNAP_PKG -q -dir $SNAP_HOME &>> ${PREFIX}/.messages.txt

# cleanup installer
rm -fr ${SNAP_HOME}/../snap-src/$SNAP_PKG


#### Update SNAP conf
echo "SNAP_HOME is ${SNAP_HOME}" &>> ${PREFIX}/.messages.txt
echo "updating snap.home ${SNAP_HOME} in  ${SNAP_HOME}/etc/snap.properties" &>> ${PREFIX}/.messages.txt
sed -i "s!#snap.home=!snap.home=${SNAP_HOME}!g" ${SNAP_HOME}/etc/snap.properties
sed -i "s!#snap.userdir=!snap.userdir=${SNAP_USER}!g" ${SNAP_HOME}/etc/snap.properties  


echo "updating default_userdir in ${SNAP_HOME}/etc/snap.conf" &>> ${PREFIX}/.messages.txt
sed -i "s!\${HOME}/.snap!${SNAP_USER}!g" ${SNAP_HOME}/etc/snap.conf  &>> ${PREFIX}/.messages.txt

### Update SNAP
echo "updating snap modules" &>> ${PREFIX}/.messages.txt
# Current workaround for "commands hang after they are actually executed":  https://senbox.atlassian.net/wiki/spaces/SNAP/pages/30539785/Update+SNAP+from+the+command+line
# /usr/local/snap/bin/snap --nosplash --nogui --modules --update-all
${SNAP_HOME}/bin/snap --nosplash --nogui --modules --update-all 2>&1 | while read -r line; do
    echo "$line"
    [ "$line" = "updates=0" ] && sleep 2 && pkill -TERM -f "snap/jre/bin/java";
done; 

echo "update concluded" &>> ${PREFIX}/.messages.txt

####
# echo "Give read/write permissions for snap home folder"  &>> ${PREFIX}/.messages.txt
# chmod -R 777 ${SNAP_USER} &>> ${PREFIX}/.messages.txt

echo "setting python_version variable" &>> ${PREFIX}/.messages.txt
python_version=$( ${PREFIX}/bin/python -c 'import sys; print("{}.{}".format(sys.version_info[0], sys.version_info[1]))' )
echo "python_version is $python_version " &>> ${PREFIX}/.messages.txt





echo "list files in ls -l ${SNAP_HOME}" &>> ${PREFIX}/.messages.txt
ls -l ${SNAP_HOME} &>> ${PREFIX}/.messages.txt
echo "ls -l ${SNAP_HOME}/../snap-src" &>> ${PREFIX}/.messages.txt
ls -l ${SNAP_HOME}/../snap-src &>> ${PREFIX}/.messages.txt


# check if ${SNAP_USER}/snap-python/snappy directory exists, if not create it
if [ -d "${SNAP_USER}/snap-python/snappy" ]
then
	echo "${SNAP_USER}/snap-python/snappy directory exists"  &>> ${PREFIX}/.messages.txt
else
	echo "creating ${SNAP_USER}/snap-python/snappy directory"  &>> ${PREFIX}/.messages.txt
	mkdir -p ${SNAP_USER}/snap-python/snappy &>> ${PREFIX}/.messages.txt
fi

# retrieving jpy wheel to copy in ${SNAP_USER}/snap-python/snappy directory
jpy_file=$(find ${PREFIX}/opt/snap-src/jpy_wheel -name "jpy-*.whl")
if [ -z "$jpy_file" ]
then
	echo "Jpy has not been installed correctly" &>> ${PREFIX}/.messages.txt
	exit 1
fi

jpy_filename=$(basename $jpy_file)

# copying jpy wheel to snappy folder
echo "Copying $jpy_file to ${SNAP_USER}/snap-python/snappy/$jpy_filename" &>> ${PREFIX}/.messages.txt
echo "running: cp ${jpy_file} ${SNAP_USER}/snap-python/snappy/$jpy_filename" &>> ${PREFIX}/.messages.txt
cp ${jpy_file} ${SNAP_USER}/snap-python/snappy/$jpy_filename &>> ${PREFIX}/.messages.txt

echo "list files in ls -l ${SNAP_USER}/snap-python/snappy" &>> ${PREFIX}/.messages.txt
ls -l ${SNAP_USER}/snap-python/snappy &>> ${PREFIX}/.messages.txt

echo "running snappy-conf: ${SNAP_HOME}/bin/snappy-conf ${PREFIX}/bin/python ${SNAP_USER}/snap-python" &>> ${PREFIX}/.messages.txt

${SNAP_HOME}/bin/snappy-conf ${PREFIX}/bin/python ${SNAP_USER}/snap-python | while read -r line; do
    echo "$line"
    [ "$line" = "or copy the 'snappy' module into your Python's 'site-packages' directory." ] && sleep 2 && pkill -TERM -f "nbexec"
done

echo " copying snappy folder to site-packages to make it importable: cp -r ${SNAP_USER}/snap-python/snappy ${PREFIX}/lib/python${python_version}/site-packages"
ln -fs ${SNAP_USER}/snap-python/snappy ${PREFIX}/lib/python${python_version}/site-packages/esasnappy &>> ${PREFIX}/.messages.txt

echo "Setting execution permissions to gdal.jar" &>> ${PREFIX}/.messages.txt
chmod +x ${SNAP_USER}/auxdata/gdal/gdal-3-*/java/gdal.jar &>> ${PREFIX}/.messages.txt


# cleanup installer
rm -fr ${SNAP_HOME}/../snap-src

# adding snap binaries to  PATH
ACTIVATE_DIR=${PREFIX}/etc/conda/activate.d
DEACTIVATE_DIR=${PREFIX}/etc/conda/deactivate.d

mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

echo "#!/bin/bash 
export PATH=${SNAP_HOME}/bin:\$PATH" >> $ACTIVATE_DIR/env_vars.sh

echo "#!/bin/bash
PATH=\$(echo \$PATH | sed -e 's@${SNAP_HOME}/bin:@@g')
export PATH=\$PATH"  >>  $DEACTIVATE_DIR/env_vars.sh
