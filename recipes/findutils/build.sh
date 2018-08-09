#!/bin/bash

autoreconf -fiv
./configure --prefix="$PREFIX"
make -j${CPU_COUNT}

#Disabling ahistorical strftime tests
sed -i.bak -e '120,126 s@.*/\* ! \*/@@' tests/test-strftime.c

#ensure tests are executable
chmod +x find/testsuite/{sv-48030-exec-plus-bug.sh,sv-48180-refuse-noop.sh}

#make mktemp commands osx compatible

sed -i.bak -e 's@mktemp -d@mktemp -d \${TMPDIR:-/tmp}/tmp.XXXXXXXXXX@' find/testsuite/sv-34079.sh
sed -i.bak -e 's@mktemp -d@mktemp -d \${TMPDIR:-/tmp}/tmp.XXXXXXXXXX@' find/testsuite/sv-34976-execdir-fd-leak.sh
sed -i.bak -e 's@mktemp -d@mktemp -d \${TMPDIR:-/tmp}/tmp.XXXXXXXXXX@' find/testsuite/sv-48030-exec-plus-bug.sh
sed -i.bak -e 's@mktemp -d@mktemp -d \${TMPDIR:-/tmp}/tmp.XXXXXXXXXX@' find/testsuite/sv-48180-refuse-noop.sh
sed -i.bak -e 's@mktemp -d@mktemp -d \${TMPDIR:-/tmp}/tmp.XXXXXXXXXX@' find/testsuite/sv-bug-32043.sh

sed -i.bak -e 's@mktemp@mktemp \${TMPDIR:-/tmp}/tmp.XXXXXXXXXX@' find/testsuite/test_escapechars.sh
sed -i.bak -e 's@mktemp@mktemp \${TMPDIR:-/tmp}/tmp.XXXXXXXXXX@' find/testsuite/test_inode.sh

make check -j${CPU_COUNT}
make install


