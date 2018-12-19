#!/bin/sh

set -ex 

PYTHON_VERSION=${PYTHON_VERSION:-3.6}
VISUS_INTERNAL_DEFAULT=${VISUS_INTERNAL_DEFAULT:-0}
DISABLE_OPENMP=${DISABLE_OPENMP:-0}
VISUS_GUI=${VISUS_GUI:-1}
CMAKE_BUILD_TYPE=RelWithDebInfo 

DEPLOY_GITHUB=${DEPLOY_GITHUB:-0}

DEPLOY_PYPI=${DEPLOY_PYPI:-0}
PYPI_USERNAME=${PYPI_USERNAME:-}
PYPI_PASSWORD=${PYPI_PASSWORD:-}
PYPI_PLAT_NAME=${PYPI_PLAT_NAME:-}

BUILD_DIR=${BUILD_DIR:-$(pwd)/build} 

# cmake options
cmake_opts=""

# //////////////////////////////////////////////////////
function DownloadFile {
	curl -fsSL --insecure "$1" -O
}

# //////////////////////////////////////////////////////
function PushCMakeOption {
	if [ -n "$2" ] ; then
		cmake_opts="${cmake_opts} -D$1=$2"
	fi
}

# //////////////////////////////////////////////////////
function PushCMakeOptions {

	PushCMakeOption PYTHON_VERSION         ${PYTHON_VERSION}
	PushCMakeOption VISUS_INTERNAL_DEFAULT ${VISUS_INTERNAL_DEFAULT}
	PushCMakeOption DISABLE_OPENMP         ${DISABLE_OPENMP}
	PushCMakeOption VISUS_GUI              ${VISUS_GUI}
	PushCMakeOption CMAKE_BUILD_TYPE       ${CMAKE_BUILD_TYPE}
	
	PushCMakeOption PYPI_USERNAME          ${PYPI_USERNAME}
	PushCMakeOption PYPI_PASSWORD          ${PYPI_PASSWORD}
	PushCMakeOption PYPI_PLAT_NAME         ${PYPI_PLAT_NAME}
	
	PushCMakeOption PYTHON_EXECUTABLE      ${PYTHON_EXECUTABLE}
	PushCMakeOption PYTHON_INCLUDE_DIR     ${PYTHON_INCLUDE_DIR}
	PushCMakeOption PYTHON_LIBRARY         ${PYTHON_LIBRARY}
	
	PushCMakeOption Qt5_DIR                ${Qt5_DIR}
}


# //////////////////////////////////////////////////////
function InstallPython {

   # need to install pyenv?
	if ! [ -x "$(command -v pyenv)" ]; then
		DownloadFile "https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer"
		chmod a+x pyenv-installer 
		./pyenv-installer 
		rm -f pyenv-installer 
	fi
	
	export PATH="$HOME/.pyenv/bin:$PATH"
	eval "$(pyenv init -)"
	eval "$(pyenv virtualenv-init -)"
	
	# pyenv install --list
	
	if [ -n "${OPENSSL_INCLUDE_DIR}" ]; then
		CONFIGURE_OPTS=--enable-shared CFLAGS=-I${OPENSSL_INCLUDE_DIR} CPPFLAGS=-I${OPENSSL_INCLUDE_DIR}/ LDFLAGS=-L${OPENSSL_LIB_DIR} pyenv install --skip-existing  ${PYTHON_VERSION}  
	else
		CONFIGURE_OPTS=--enable-shared pyenv install --skip-existing ${PYTHON_VERSION}  
	fi
	
	pyenv global ${PYTHON_VERSION}  
	pyenv rehash
	python -m pip install --upgrade pip  
	python -m pip install --upgrade numpy setuptools wheel twine auditwheel 

	if [ "${PYTHON_VERSION:0:1}" -gt "2" ]; then
		PYTHON_M_VERSION=${PYTHON_VERSION:0:3}m 
	else
		PYTHON_M_VERSION=${PYTHON_VERSION:0:3}
	fi	
  
	export PYTHON_EXECUTABLE=$(pyenv prefix)/bin/python 
	export PYTHON_INCLUDE_DIR=$(pyenv prefix)/include/python${PYTHON_M_VERSION} 
	
	if [[ $(uname) == "Darwin" ]]; then
		export PYTHON_LIBRARY=$(pyenv prefix)/lib/libpython${PYTHON_M_VERSION}.dylib
	else
		
		export PYTHON_LIBRARY=$(pyenv prefix)/lib/libpython${PYTHON_M_VERSION}.so
	fi
}





