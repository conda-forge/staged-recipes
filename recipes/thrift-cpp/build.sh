#!/bin/env bash

# FIXME: This is a hack to make sure the environment is activated.
# The reason this is required is due to the conda-build issue
# mentioned below.
#
# https://github.com/conda/conda-build/issues/910
#
source activate "${CONDA_DEFAULT_ENV}"


BOOST_ROOT=$PREFIX
ZLIB_ROOT=$PREFIX
LIBEVENT_ROOT=$PREFIX

export OPENSSL_ROOT=$PREFIX
export OPENSSL_ROOT_DIR=$PREFIX

export CXXFLAGS="${CXXFLAGS} -fPIC"

cmake \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DBUILD_PYTHON=off \
	-DBUILD_JAVA=off \
	-DBUILD_C_GLIB=off \
	.

make

# TODO(wesm): The unit tests do not run in CircleCI at the moment
# make check

make install
