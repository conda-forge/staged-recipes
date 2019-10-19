#!/bin/sh

# Installation following the instructions in 
# https://htmlpreview.github.io/?https://github.com/DOCGroup/ACE_TAO/blob/master/ACE/ACE-INSTALL.html#unix
export ACE_ROOT=$SRC_DIR/ACE_wrappers 

printf '#include "ace/config-linux.h"\n' > ${ACE_ROOT}/ace/config.h
printf "include $(ACE_ROOT)/include/makeinclude/platform_linux.GNU\nINSTALL_PREFIX = /usr/local\n" > ${ACE_ROOT}/include/makeinclude/platform_macros.GNU

make -j${CPU_COUNT}
make install
