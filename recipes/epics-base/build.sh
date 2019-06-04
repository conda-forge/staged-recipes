#!/bin/bash
install -d $PREFIX/bin
install -d $PREFIX/lib
install -d $PREFIX/epics

# export EPICS_HOST_ARCH as determined
EPICS_HOST_ARCH=$(perl src/tools/EpicsHostArch.pl)
export EPICS_HOST_ARCH

make \
    CMPLR_PREFIX="${HOST}-" \
    G++="${CXX}" \
    GNU_DIR="${BUILD_PREFIX}" \
    -j ${CPU_COUNT}

EPICS_BASE=$PREFIX/epics

# Copy libraries into $PREFIX/lib
cp -av $PREFIX/epics/lib/$EPICS_HOST_ARCH/lib*${SHLIB_EXT}* $PREFIX/lib

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
