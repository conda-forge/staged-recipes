#!/bin/bash

set -e
set -x

sh bootstrap

./configure \
    --prefix=${PREFIX} \
    --host=${HOST} \
|| cat config.log

make -j${CPU_COUNT} ${VERBOSE_AT}
make install



# # Includes man pages and other miscellaneous.
# rm -rf "${PREFIX}/share"



# override the default ROSWELL_HOME
mkdir -p ${PREFIX}/bin/roswell/
mv -v ${PREFIX}/bin/ros ${PREFIX}/bin/roswell/ros
cat > ${PREFIX}/bin/ros <<EOF
#!/bin/bash
ROSWELL_HOME=\${CONDA_PREFIX}/roswell \${CONDA_PREFIX}/bin/roswell/ros
>>EOF

