#!/bin/sh

set -e -o pipefail -x

python setup.py install --single-version-externally-managed --record record.txt
mv $PREFIX/bin/patool $PREFIX/bin/patool_orig.py
echo '#!/bin/sh' > $PREFIX/bin/patool
echo >> $PREFIX/bin/patool
echo 'set -e -o pipefail' >> $PREFIX/bin/patool
echo -n "python $PREFIX/bin/patool_orig.py " >> $PREFIX/bin/patool
echo '"$@"' >> $PREFIX/bin/patool
chmod u+x $PREFIX/bin/patool

