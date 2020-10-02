#!/bin/sh

# Installation following the instructions in 
# https://htmlpreview.github.io/?https://github.com/DOCGroup/ACE_TAO/blob/master/ACE/ACE-INSTALL.html#unix
export ACE_ROOT=${SRC_DIR}
export ACE_SOURCE_PATH=${ACE_ROOT}/ace
export WORKSPACE=${ACE_ROOT}/ace/ace
export INSTALL_PREFIX=$PREFIX
export PERL_PATH=$CONDA_PREFIX/bin/perl

# Configure step
cd ${ACE_ROOT}
perl ${ACE_ROOT}/bin/mwc.pl -type gnuace -features "uses_wchar=1,zlib=0,ssl=0,openssl11=0,trio=0,xt=0,fl=0,fox=0,tk=0,qt=0,rapi=0,stlport=0,rwho=0" ${WORKSPACE}.mwc

if [[ $target_platform == osx* ]]
then
  echo "Detected OS X"
  printf "#include \"ace/config-macosx.h\"" > ${ACE_SOURCE_PATH}/config.h
  printf "include ${ACE_ROOT}/include/makeinclude/platform_macosx.GNU" > ${ACE_ROOT}/include/makeinclude/platform_macros.GNU
else
  echo "Detected Linux"
  printf "#include \"ace/config-linux.h\"" > ${ACE_SOURCE_PATH}/config.h
  printf "include ${ACE_ROOT}/include/makeinclude/platform_linux.GNU" > ${ACE_ROOT}/include/makeinclude/platform_macros.GNU
fi

cat ${ACE_SOURCE_PATH}/config.h
cat ${ACE_ROOT}/include/makeinclude/platform_macros.GNU

# Build step
cd ${ACE_SOURCE_PATH}
# The BUILD enviroment variable set by conda script conflict with the ACE's makefile,
# so we set it to an empty value just to run make and make install
export ACE_BUILD_ENV_BACKUP=${BUILD}
export BUILD=
make -j${CPU_COUNT}

# Install step
make install

export BUILD=${ACE_BUILD_ENV_BACKUP}



