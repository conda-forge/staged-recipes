#!/bin/bash

set -exuo pipefail

mkdir -p $PREFIX/lib/java
mkdir -p $PREFIX/bin
cp $SRC_DIR/toolsUI-$PKG_VERSION.jar $PREFIX/lib/java/toolsUI.jar

cat <<'EOF' >${PREFIX}/bin/ncj-toolsui
#!/bin/sh
SCRIPT=`readlink -f $0`
SCRIPTDIR=`dirname $SCRIPT`
java -Xms512m -Xmx4g $JAVA_OPTS -cp $SCRIPTDIR/../lib/java/toolsUI.jar ucar.nc2.ui.ToolsUI "$@"
EOF
chmod +x ${PREFIX}/bin/ncj-toolsui

cat <<'EOF' >${PREFIX}/bin/ncj-nccopy
#!/bin/sh
SCRIPT=`readlink -f $0`
SCRIPTDIR=`dirname $SCRIPT`
java -Xms512m -Xmx4g $JAVA_OPTS -cp $SCRIPTDIR/../lib/java/toolsUI.jar ucar.nc2.write.Nccopy "$@"
EOF
chmod +x ${PREFIX}/bin/ncj-nccopy

cat <<'EOF' >${PREFIX}/bin/ncj-ncdump
#!/bin/sh
SCRIPT=`readlink -f $0`
SCRIPTDIR=`dirname $SCRIPT`
java -Xms512m -Xmx4g $JAVA_OPTS -cp $SCRIPTDIR/../lib/java/toolsUI.jar ucar.nc2.NCdumpW "$@"
EOF
chmod +x ${PREFIX}/bin/ncj-ncdump

cat <<'EOF' >${PREFIX}/bin/ncj-nccompare
#!/bin/sh
SCRIPT=`readlink -f $0`
SCRIPTDIR=`dirname $SCRIPT`
java -Xms512m -Xmx4g $JAVA_OPTS -cp $SCRIPTDIR/../lib/java/toolsUI.jar ucar.nc2.util.CompareNetcdf2 "$@"
EOF
chmod +x ${PREFIX}/bin/ncj-nccompare

cat <<'EOF' >${PREFIX}/bin/ncj-bufrspliter
#!/bin/sh
SCRIPT=`readlink -f $0`
SCRIPTDIR=`dirname $SCRIPT`
java -Xms512m -Xmx4g $JAVA_OPTS -cp $SCRIPTDIR/../lib/java/toolsUI.jar ucar.nc2.iosp.bufr.writer.BufrSplitter "$@"
EOF
chmod +x ${PREFIX}/bin/ncj-bufrspliter

cat <<'EOF' >${PREFIX}/bin/ncj-cfpointwriter
#!/bin/sh
SCRIPT=`readlink -f $0`
SCRIPTDIR=`dirname $SCRIPT`
java -Xms512m -Xmx4g $JAVA_OPTS -cp $SCRIPTDIR/../lib/java/toolsUI.jar ucar.nc2.ft.point.writer.CFPointWriter "$@"
EOF
chmod +x ${PREFIX}/bin/ncj-cfpointwriter

cat <<'EOF' >${PREFIX}/bin/ncj-gribcdmindex
#!/bin/sh
SCRIPT=`readlink -f $0`
SCRIPTDIR=`dirname $SCRIPT`
java -Xms512m -Xmx4g $JAVA_OPTS -cp $SCRIPTDIR/../lib/java/toolsUI.jar ucar.nc2.grib.collection.GribCdmIndex "$@"
EOF
chmod +x ${PREFIX}/bin/ncj-gribcdmindex

cat <<'EOF' >${PREFIX}/bin/ncj-featurescan
#!/bin/sh
SCRIPT=`readlink -f $0`
SCRIPTDIR=`dirname $SCRIPT`
java -Xms512m -Xmx4g $JAVA_OPTS -cp $SCRIPTDIR/../lib/java/toolsUI.jar ucar.nc2.ft2.scan.FeatureScan "$@"
EOF
chmod +x ${PREFIX}/bin/ncj-featurescan

cat <<'EOF' >${PREFIX}/bin/ncj-catalogcrawler
#!/bin/sh
SCRIPT=`readlink -f $0`
SCRIPTDIR=`dirname $SCRIPT`
java -Xms512m -Xmx4g $JAVA_OPTS -cp $SCRIPTDIR/../lib/java/toolsUI.jar thredds.client.catalog.tools.CatalogCrawler "$@"
EOF
chmod +x ${PREFIX}/bin/ncj-catalogcrawler

