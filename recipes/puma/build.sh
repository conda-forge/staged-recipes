
echo "Starting compilation of PuMA."

if [ "$(uname)" == "Darwin" ]; then
    s=${BASH_SOURCE[0]} ; s=`dirname $s` ; PuMA_DIR=`cd $s/../.. ; pwd`
    PuMA_OS="Mac"

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    PuMA_DIR="$(echo "$( dirname "$( dirname "$( dirname "$(readlink -f -- "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")")")")")"
    PuMA_OS="Linux"
else
    echo "Unrecongnized Operating System, PuMA cannot be installed."
    exit 1
fi

./cpp/src/createCMakeLists_src.sh
./cpp/test/createCMakeLists_test.sh

cd install 

# echo BUILD_PREFIX
# echo $BUILD_PREFIX
# echo PREFIX
# echo $PREFIX
# echo PATH
# echo $PATH
# echo PYTHON
# echo $PYTHON
# echo RECIPE_DIR
# echo $RECIPE_DIR
# echo SP_DIR
# echo $SP_DIR
# echo SRC_DIR
# echo $SRC_DIR
# echo STDLIB_DIR
# echo $STDLIB_DIR
# echo PKG_CONFIG_PATH
# echo $PKG_CONFIG_PATH
# echo LDFLAGS
# echo $LDFLAGS

mkdir -p cmake-build-release
cd cmake-build-release
cmake ../../cpp
make -j
make install
