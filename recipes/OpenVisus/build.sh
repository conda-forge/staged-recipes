#/usr/bin/env bash

set -ex 

PYTHON_VERSION=${PYTHON_VERSION:-3.6.6}
CMAKE_BUILD_TYPE=RelWithDebInfo 
BUILD_DIR=${BUILD_DIR:-$(pwd)/build/manylinux} 

SOURCE_DIR=$(pwd)
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# //////////////////////////////////////////////////////
function DownloadFile {
	curl -fsSL --insecure "$1" -O
}

# //////////////////////////////////////////////////////
function PushCMakeOption {
	if [ -n "$2" ] ; then
		cmake_opts+=" -D$1=$2"
	fi
}

# //////////////////////////////////////////////////////
# NOTE for linux: mixing python openssl and OpenVisus internal openssl cause crashes so I'm always using this one
function InstallOpenSSL {

	if [ ! -f $BUILD_DIR/openssl/lib/libssl.a ]; then
		echo "Compiling openssl"
		DownloadFile "https://www.openssl.org/source/openssl-1.0.2a.tar.gz"
		tar xvzf openssl-1.0.2a.tar.gz 
		pushd openssl-1.0.2a 
		./config -fpic shared 
		make 
		make install	
		popd
	fi
	
	export OPENSSL_ROOT_DIR=/usr/local/ssl
	export OPENSSL_INCLUDE_DIR=${OPENSSL_ROOT_DIR}/include 
	export OPENSSL_LIB_DIR=${OPENSSL_ROOT_DIR}/lib
	export LD_LIBRARY_PATH=${OPENSSL_LIB_DIR}:$LD_LIBRARY_PATH
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
	
	if [ -n "${OPENSSL_INCLUDE_DIR}" ]; then
		CONFIGURE_OPTS=--enable-shared CFLAGS=-I${OPENSSL_INCLUDE_DIR} CPPFLAGS=-I${OPENSSL_INCLUDE_DIR}/ LDFLAGS=-L${OPENSSL_LIB_DIR} pyenv install --skip-existing  ${PYTHON_VERSION}  
	else
		CONFIGURE_OPTS=--enable-shared pyenv install --skip-existing ${PYTHON_VERSION}  
	fi
	
	pyenv global ${PYTHON_VERSION}  
	pyenv rehash
	python -m pip install --upgrade pip  
	python -m pip install numpy setuptools wheel twine auditwheel 

	if [ "${PYTHON_VERSION:0:1}" -gt "2" ]; then
		PYTHON_M_VERSION=${PYTHON_VERSION:0:3}m 
	else
		PYTHON_M_VERSION=${PYTHON_VERSION:0:3}
	fi	
  
	export PYTHON_EXECUTABLE=$(pyenv prefix)/bin/python 
	export PYTHON_INCLUDE_DIR=$(pyenv prefix)/include/python${PYTHON_M_VERSION} 
	export PYTHON_LIBRARY=$(pyenv prefix)/lib/libpython${PYTHON_M_VERSION}.so
}


# //////////////////////////////////////////////////////
function InstallSwig {
	if [ ! -f $BUILD_DIR/swig/bin/swig ]; then
		DownloadFile "https://ftp.osuosl.org/pub/blfs/conglomeration/swig/swig-3.0.12.tar.gz"  
		tar xvzf swig-3.0.12.tar.gz 
		pushd swig-3.0.12 
		DownloadFile "https://ftp.pcre.org/pub/pcre/pcre-8.42.tar.gz"
		./Tools/pcre-build.sh 
		./configure 
		make -j 4 
		make install 
		popd
	fi 
	export PATH=$BUILD_DIR/swig/bin:${PATH} 
}

# //////////////////////////////////////////////////////
function InstallCMake {

	if ! [ -x "$BUILD_DIR/cmake/bin/cmake" ]; then
		echo "Downloading precompiled cmake"
		DownloadFile "http://www.cmake.org/files/v3.4/cmake-3.4.3-Linux-x86_64.tar.gz"
		tar xvzf cmake-3.4.3-Linux-x86_64.tar.gz
		mv cmake-3.4.3-Linux-x86_64 ${BUILD_DIR}/cmake
	fi
	
	export PATH=$BUILD_DIR/cmake/bin:${PATH} 
}

yum update 
yum install -y zlib-devel curl 
yum install -y httpd.x86_64 httpd-devel.x86_64

InstallOpenSSL 
InstallPython 
InstallCMake    
InstallSwig

# broken right now
# InstallQt  

cmake_opts=""
PushCMakeOption PYTHON_VERSION         ${PYTHON_VERSION}
PushCMakeOption CMAKE_BUILD_TYPE       ${CMAKE_BUILD_TYPE}
PushCMakeOption VISUS_INTERNAL_DEFAULT 1
PushCMakeOption DISABLE_OPENMP         1
PushCMakeOption VISUS_GUI              0
PushCMakeOption OPENSSL_ROOT_DIR       ${OPENSSL_ROOT_DIR}
PushCMakeOption PYTHON_EXECUTABLE      ${PYTHON_EXECUTABLE}
PushCMakeOption PYTHON_INCLUDE_DIR     ${PYTHON_INCLUDE_DIR}
PushCMakeOption PYTHON_LIBRARY         ${PYTHON_LIBRARY}
PushCMakeOption PYTHON_PLAT_NAME       manylinux1_x86_64
PushCMakeOption PYPI_USERNAME          ${PYPI_USERNAME}
PushCMakeOption PYPI_PASSWORD          ${PYPI_PASSWORD}

cmake ${cmake_opts} ${SOURCE_DIR} 
cmake --build . --target all -- -j 4
cmake --build . --target test

cmake --build . --target install 

if (( 0 )); then
	# WRONG copying very low-level libraries is wrong (i.e. crashes)! I need only distribute real dependencies
	# cmake --build . --target deploy 
	echo "nop"
else
	# NOTE: sometimes docker containers do not contain the python shared library (needed for executables) so I'm copying it too
	cp ${OPENSSL_LIB_DIR}/libcrypto.so*      install/bin/
	cp ${OPENSSL_LIB_DIR}/libssl.so*         install/bin/
	cp $(pyenv prefix)/lib/libpython* install/bin/ 
fi

pushd install
LD_LIBRARY_PATH=$(pwd)/bin:$(dirname ${PYTHON_LIBRARY}) PYTHONPATH=$(pwd) bin/visus                                  && echo "Embedding working"
LD_LIBRARY_PATH=$(pwd)/bin                              PYTHONPATH=$(pwd) ${PYTHON_EXECUTABLE} -c "import OpenVisus" && echo "Extending working"
popd

if (( DEPLOY_GITHUB == 1 )); then
	cmake --build ./ --target sdist --config ${CMAKE_BUILD_TYPE}	
fi

if (( DEPLOY_PYPI == 1 )); then
	cmake --build ./ --target bdist_wheel --config ${CMAKE_BUILD_TYPE} 
	cmake --build ./ --target pypi        --config ${CMAKE_BUILD_TYPE}
fi

