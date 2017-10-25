#!/bin/sh

set -e -o pipefail -x

python setup.py install --single-version-externally-managed --record record.txt
mv $PREFIX/bin/patool $PREFIX/bin/patool_orig
echo '#!/usr/bin/env python' > $PREFIX/bin/patool
cat $PREFIX/bin/patool_orig >> $PREFIX/bin/patool
chmod u+x $PREFIX/bin/patool
