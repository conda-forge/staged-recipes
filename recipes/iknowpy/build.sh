#!/usr/bin/env bash

# Build manylinux wheels for Python 3.8 through Python 3.12. This script must be
# executed inside a manylinux container in which /iknow is the root of the
# repository.
#
# Usage: /iknow/actions/build_manylinux.sh
#
# Required Environment Variables:
# - CCACHE_MAXSIZE is the size limit for files held with ccache
# - PIP_CACHE_DIR is the location that pip caches files
# - ICU_URL is the URL to a .tgz source release of ICU
# - JSON_URL is the URL of .zip release of JSON for Modern C++

set -euxo pipefail


# ##### Install and configure dependencies #####
# # epel-release
# #   Needed to install ccache on some platforms.
# # ccache
# #   Speed up build times by caching results from previous builds.
# PROCESSOR="$(uname -p)"
# if [ "$PROCESSOR" = aarch64 ] || [ "$PROCESSOR" = ppc64le ]; then
#   yum -y install epel-release
#   # this mirror is often slow, so disable it
#   echo "exclude=mirror.es.its.nyu.edu" >> /etc/yum/pluginconf.d/fastestmirror.conf
# else
#   echo "exclude=mirror.es.its.nyu.edu mirrors.tripadvisor.com" >> /etc/yum/pluginconf.d/fastestmirror.conf
# fi
# yum install -y ccache
# mkdir -p /opt/ccache
# ln -s /usr/bin/ccache /opt/ccache/cc
# ln -s /usr/bin/ccache /opt/ccache/c++
# ln -s /usr/bin/ccache /opt/ccache/gcc
# ln -s /usr/bin/ccache /opt/ccache/g++
# export PATH="/opt/ccache:$PATH"


# ##### Build ICU if it's not cached #####
# export ICUDIR=/iknow/thirdparty/icu
# if ! [ -f "$ICUDIR/iknow_icu_url.txt" ] || [ $(cat "$ICUDIR/iknow_icu_url.txt") != "$ICU_URL" ]; then
#   rm -rf "$ICUDIR"
#   curl -L -o icu4c-src.tgz "$ICU_URL"
#   tar xfz icu4c-src.tgz
#   cd icu/source
#   PYTHON=/opt/python/cp312-cp312/bin/python CXXFLAGS=-std=c++11 ./runConfigureICU Linux --prefix="$ICUDIR"
#   make -j $(nproc)
#   make install
#   echo "$ICU_URL" > "$ICUDIR/iknow_icu_url.txt"
# fi

PROCESSOR="$(uname -p)"

##### Install JSON for Modern C++ if it's not cached #####
export JSONDIR=/iknow/thirdparty/json
export JSON_INCLUDE=$JSONDIR/single_include
if ! [ -f "$JSONDIR/iknow_json_url.txt" ] || [ $(cat "$JSONDIR/iknow_json_url.txt") != "$JSON_URL" ]; then
    rm -rf "$JSONDIR"
    mkdir -p "$JSONDIR"
    curl -L -o json_for_modern_cpp.zip "$JSON_URL"
    unzip -q -d "$JSONDIR" json_for_modern_cpp.zip
    echo "$JSON_URL" > "$JSONDIR/iknow_json_url.txt"
fi

##### Build iKnow engine and run C++ unit tests #####
cd /iknow

case "$PROCESSOR" in
  x86_64)
    export IKNOWPLAT=lnxrhx64
    ;;
  aarch64)
    export IKNOWPLAT=lnxrharm64
    ;;
  ppc64le)
    export IKNOWPLAT=lnxrhppc64le
    ;;
  *)
    echo "Processor type $PROCESSOR is not supported"
    exit 1
    ;;
esac

make -j $(nproc) test


##### Build iknowpy wheels #####
git config --global --add safe.directory /iknow
cd modules/iknowpy
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/iknow/kit/$IKNOWPLAT/release/bin:$ICUDIR/lib"

# install Python package dependencies and build initial wheels
chown -R root "$PIP_CACHE_DIR"
for PYTHON in /opt/python/{cp38-cp38,cp39-cp39,cp310-cp310,cp311-cp311,cp312-cp312}/bin/python
do
  "$PYTHON" -m pip install --user cython=="$CYTHON_VERSION" setuptools wheel --no-warn-script-location
  "$PYTHON" setup.py bdist_wheel --no-dependencies
done
"$PYTHON" setup.py merge --no-dependencies
chmod -R a+rw "$PIP_CACHE_DIR"

# repair wheel using auditwheel to convert to manylinux wheel
auditwheel repair dist/merged/iknowpy-*.whl


##### Report cache statistics #####
ccache -s