#!/bin/bash

echo "removing SNAP package $PREFIX/snap" &>> $PREFIX/.messages.txt
rm -fr $PREFIX/snap &>> $PREFIX/.messages.txt

echo "removing SNAPPY package " &>> $PREFIX/.messages.txt
python_version=$( $PREFIX/bin/python -c 'import sys; print("{}.{}".format(sys.version_info[0], sys.version_info[1]))' )
rm -fr  $PREFIX/lib/python${python_version}/site-packages/snappy &>> $PREFIX/.messages.txt