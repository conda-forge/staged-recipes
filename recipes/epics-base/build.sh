#!/bin/bash
install -d $PREFIX/bin
install -d $PREFIX/lib
install -d $PREFIX/epics

#make -j$(getconf _NPROCESSORS_ONLN)
make

EPICS_BASE=$PREFIX/epics
EPICS_HOST_ARCH=$(startup/EpicsHostArch)

# Copy libraries into $PREFIX/lib
cp -av $PREFIX/epics/lib/$EPICS_HOST_ARCH/lib*so* $PREFIX/lib

# Setup symlinks for utilities
BINS="caget caput camonitor softIoc"
cd $PREFIX/bin
for file in $BINS ; do
	ln -s ../epics/bin/$EPICS_HOST_ARCH/$file .
done

# deal with env export
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

ACTIVATE=$PREFIX/etc/conda/activate.d/epics_base.sh
DEACTIVATE=$PREFIX/etc/conda/deactivate.d/epics_base.sh
ETC=$PREFIX/etc

# set up
echo "export EPICS_BASE="$EPICS_BASE >> $ACTIVATE
echo "export EPICS_HOST_ARCH="$EPICS_HOST_ARCH >> $ACTIVATE

# tear down
echo "unset EPICS_BASE" >> $DEACTIVATE
echo "unset EPICS_HOST_ARCH" >> $DEACTIVATE

# clean up after self
unset ACTIVATE
unset DEACTIVATE
unset ETC
