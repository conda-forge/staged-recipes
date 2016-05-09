$PYTHON setup.py install

mkdir -p $PREFIX/etc/supervisord/conf.d
mkdir -p $PREFIX/etc/supervisord/startup
mkdir -p $PREFIX/var/log/supervisord
mkdir -p $PREFIX/var/run/supervisord

cp $RECIPE_DIR/supervisord.conf $PREFIX/etc/supervisord/
ln -s $PREFIX/etc/supervisord/supervisord.conf $PREFIX/etc/supervisord.conf


mkdir -p $PREFIX/etc/rc.d/init.d/
cp $RECIPE_DIR/Debian-supervisord $PREFIX/etc/rc.d/init.d/
cp $RECIPE_DIR/RedHat-supervisord $PREFIX/etc/rc.d/init.d/


mkdir -p $PREFIX/etc/systemd/system/
cp $RECIPE_DIR/supervisord.service $PREFIX/etc/systemd/system/
