export INSTALL_LOCATION=$CONDA_PREFIX/etc/mercurial

/bin/mkdir -p $CONDA_PREFIX/etc $INSTALL_LOCATION $INSTALL_LOCATION/hggit
cd hggit
/bin/cp -a ./. $INSTALL_LOCATION/hggit

touch $INSTALL_LOCATION/hgrc

echo "[extensions]" >> $INSTALL_LOCATION/hgrc

echo "hgext.bookmarks = " >> $INSTALL_LOCATION/hgrc
echo "hggit = $INSTALL_LOCATION/hggit" >> $INSTALL_LOCATION/hgrc
