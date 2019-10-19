#!/bin/sh

# Installation following the instructions in 
# https://htmlpreview.github.io/?https://github.com/DOCGroup/ACE_TAO/blob/master/ACE/ACE-INSTALL.html#unix
export ACE_ROOT=${SRC_DIR}/ACE_wrappers 
echo "ACE_ROOT is $ACE_ROOT (${ACE_ROOT})"
echo "SRC_DIR is $SRC_DIR (${SRC_DIR})"


printf '#include "ace/config-linux.h"\n' > ${ACE_ROOT}/ace/config.h
cat ${ACE_ROOT}/ace/config.h
echo "Header generated in ${ACE_ROOT}/ace/config.h"
printf "include $(ACE_ROOT)/include/makeinclude/platform_linux.GNU\nINSTALL_PREFIX = /usr/local\n" > ${ACE_ROOT}/include/makeinclude/platform_macros.GNU

make -j${CPU_COUNT}
make install
