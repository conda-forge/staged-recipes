#!/bin/bash

###########################################################################  
# Copyright Sugato Ray.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###########################################################################


# Specific Example:
#------------------
# mkdir -p temp_doubtlab && \
#     curl https://pypi.io/packages/source/d/doubtlab/doubtlab-0.1.1.tar.gz \
#         -o temp_doubtlab/doubtlab-0.1.1.tar.gz && \
#     echo $(openssl sha256 temp_doubtlab/doubtlab-0.1.1.tar.gz | grep SHA256 | cut -d "=" -f2 | xargs)

# Function to fetch sha256 checksum of a local file
function getsha256() {
    _PKG_NAME=$1
    echo "$(openssl sha256 ${_PKG_NAME} | grep "SHA256" | cut -d "=" -f2 | xargs)"
    unset _PKG_NAME
}

# Function to fetch sha256 checksum of a package on pypi/other url
function fetch_sha256() {
    ## Usage:
    ## fetch_sha256 $PACKAGE_NAME $PACKAGE_URL
    _PACKAGE_NAME=$1
    _PACKAGE_URL=$2
    _TEMP_DIR=temp_"$_PACKAGE_NAME"
    _TAR_GZ_FILENAME=$(basename "$_PACKAGE_URL")
    mkdir -p $_TEMP_DIR && \
        # apply curl to download the tar.gz package "silently" inside _TEMP_DIR
        curl -s "$_PACKAGE_URL" -o "$_TEMP_DIR"/"$_TAR_GZ_FILENAME" && \
        # extract sha256 value from the package and store in variable PACKAGE_SHA256
        # PACKAGE_SHA256="$(openssl sha256 "$_TEMP_DIR"/"$_TAR_GZ_FILENAME" | grep "SHA256" | cut -d "=" -f2 | xargs)" && \
        PACKAGE_SHA256="$(getsha256 "${_TEMP_DIR}/${_TAR_GZ_FILENAME}")" && \
        # export PACKAGE_SHA256 as an environment variable
        export PACKAGE_SHA256=$PACKAGE_SHA256 && \
        # delete (recursively + forcibly) the folder and its contents: _TEMP_DIR
        rm -rf $_TEMP_DIR && \
        # echo out the sha256-value
        echo ${PACKAGE_SHA256}

    unset \
        _PACKAGE_NAME \
        _PACKAGE_URL \
        _TEMP_DIR \
        _TAR_GZ_FILENAME
}

# Function to fetch sha256 checksum of a package SPECIFICALLY from PyPI
function pypi_sha256() {
    ## Usage:
    ## pypi_sha256 $PACKAGE_NAME $PACKAGE_VERSION
    _PYPI_PKG_NAME=$1
    _PYPI_PKG_VERSION=$2
    _PYPI_PKG_URL='https://pypi.io/packages/source/"${_PYPI_PKG_NAME:0:1}"/"${_PYPI_PKG_NAME}"/"${_PYPI_PKG_NAME}"-"${_PYPI_PKG_VERSION}".tar.gz'
    # Note:
    # - To extract the nth letter from a string, use this syntax: ${str:position:length}
    # - ${TEXT_VAR:0:1} will return the first letter from the variable TEXT_VAR.
    # - source: https://stackoverflow.com/questions/10218474/how-to-obtain-the-first-letter-in-a-bash-variable
    fetch_sha256 $_PYPI_PKG_NAME $_PYPI_PKG_URL
    unset \
        _PYPI_PKG_NAME \
        _PYPI_PKG_VERSION \
        _PYPI_PKG_URL
}
