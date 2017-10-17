#!/bin/sh

set -e -o pipefail

export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"
./configure --prefix=${PREFIX} --disable-dependency-tracking --enable-only64bit LDFLAGS="${LDFLAGS}"

SYSLWR=`uname | tr '[:upper:]' '[:lower:]'`

mv ${SRC_DIR}/coregrind/link_tool_exe_${SYSLWR} ${SRC_DIR}/coregrind/link_tool_exe_${SYSLWR}_orig
echo '#!/usr/bin/env perl' >> ${SRC_DIR}/coregrind/link_tool_exe_${SYSLWR}
cat ${SRC_DIR}/coregrind/link_tool_exe_${SYSLWR}_orig >> ${SRC_DIR}/coregrind/link_tool_exe_${SYSLWR}
chmod u+x ${SRC_DIR}/coregrind/link_tool_exe_${SYSLWR}

make
make install
