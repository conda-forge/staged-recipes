#!/usr/bin/env bash

BUILD_CACHE="${RECIPE_DIR}/../build/cache"
mkdir -p ${BUILD_CACHE}
UNAME=$(uname)
if [[ ${UNAME} == "Linux" ]]; then
  # Linux
  URL="http://download.oracle.com/otn-pub/java/jdk/8u25-b17/jdk-8u25-linux-x64.tar.gz"
  JDK="jdk.tar.gz"
  NSTRIP=1
  LINKLOC="${PREFIX}/lib/*/jli"
else
  # MacOSX
  URL="http://download.oracle.com/otn-pub/java/jdk/8u25-b17/jdk-8u25-macosx-x64.dmg"
  JDK="jdk.dmg"
  NSTRIP=3
  LINKLOC="${PREFIX}/lib/jli"
fi

# this must exist because ln does not have the -r option in Mac. Apple, unix - but not!
relpath(){ python -c "import os.path; print(os.path.relpath('$1','${2:-$PWD}'))" ; }

# These must exist because Oracle only supports dmg-based distribution of jdk right now
# and the we have to do silly Apple things to install from dmg. Life is pain.
split0(){ python -c "print('$@'.strip().split(None, 1)[0])"; }
split2up(){ python -c "print('$@'.strip().split(None, 2)[-1])"; }

# Download
if [ ! -f ${BUILD_CACHE}/${JDK} ]; then
  curl -L -C - -b "oraclelicense=accept-securebackup-cookie" -o $BUILD_CACHE/$JDK $URL
fi
cp -v ${BUILD_CACHE}/${JDK} ${JDK}

# Install
if [[ ${UNAME} == "Linux" ]]; then
  # Linux
  tar xvf ${JDK} --strip-components=${NSTRIP} -C ${PREFIX}
else
  # Mac OSX, inspired by
  # http://commandlinemac.blogspot.com/2008/12/installing-dmg-application-from-command.html
  # and
  # http://stackoverflow.com/questions/15217200/how-to-install-java-7-on-mac-in-custom-location
  MNT_TAIL=$(hdiutil mount ${JDK} | tail -n 1)
  MNT_POINT=$(split0 "${MNT_TAIL}")
  MNT_NAME=$(split2up "${MNT_TAIL}")
  pkgutil --expand  "${MNT_NAME}"/JDK*.pkg ${PREFIX}/tmp-jdkpkg
  hdiutil unmount "${MNT_POINT}"
  PREV_DIR=$(pwd)
  cd ${PREFIX}/tmp-jdkpkg
  cpio -i < ./jdk*.pkg/Payload
  mv Contents/Home/* ${PREFIX}
  cd ${PREV_DIR}
  rm -rf ${PREFIX}/tmp
fi
JLI_REL=$(relpath $(ls ${LINKLOC}/*jli.*) ${PREFIX}/lib)
ln -s ${JLI_REL} ${PREFIX}/lib

# Some clean up
rm -rf ${PREFIX}/release ${PREFIX}/README ${PREFIX}/Welcome.html ${PREFIX}/*jli.*
chmod og+w ${PREFIX}/COPYRIGHT ${PREFIX}/LICENSE ${PREFIX}/THIRDPARTYLICENSEREADME.txt
mv ${PREFIX}/COPYRIGHT ${PREFIX}/COPYRIGHT-JDK
mv ${PREFIX}/LICENSE $PREFIX/LICENSE-JDK
mv ${PREFIX}/THIRDPARTYLICENSEREADME.txt ${PREFIX}/THIRDPARTYLICENSEREADME-JDK.txt

# Mac specific cleanup
if [[ ${UNAME} == "Darwin" ]]; then
  rm -rf ${PREFIX}/lib/lib
  rm -f ${PREFIX}/lib/visualvm/profiler/lib/deployed/jdk15/mac/*.jnilib
fi
