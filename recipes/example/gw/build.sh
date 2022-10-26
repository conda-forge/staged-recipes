

set -x -e

INCLUDE_PATH="${PREFIX}/include"
LIBRARY_PATH="${PREFIX}/lib"

if [ "$(uname)" == "Darwin" ]; then
    MACOSX_VERSION_MIN=10.6
    CXXFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    CXXFLAGS="${CXXFLAGS} -stdlib=libstdc++"
    LINKFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LINKFLAGS="${LINKFLAGS} -stdlib=libstdc++ -L${LIBRARY_PATH}"

#    make

fi

if [ "$(uname)" == "Linux" ]; then
    CXXFLAGS="${CXXFLAGS} -stdlib=libstdc++"
    LINKFLAGS="${LINKFLAGS} -stdlib=libstdc++ -L${LIBRARY_PATH}"
    LDFLAGS="${LIBRARY_PATH} -pthread"
#    cd ../
#    pwd
#    exit

#    wget https://github.com/samtools/htslib/releases/download/1.16/htslib-1.16.tar.bz2 && \
#    tar -xvf htslib-1.16.tar.bz2 && cd htslib-1.16
#    autoreconf -i
#    ./configure
#    make -j16
#    make install
#    cd ../ && ls

#    wget https://github.com/glfw/glfw/releases/download/3.3.8/glfw-3.3.8.zip && \
#    unzip glfw-3.3.8.zip && cd glfw-3.3.8
#    cmake -S . -B build
#    cd build
#    make -j16
#    make install
#    cd ../../

#    mkdir -p skia
#    cd skia && \
#    wget https://github.com/JetBrains/skia-build/releases/download/m93-87e8842e8c/Skia-m93-87e8842e8c-linux-Release-x64.zip && \
#    unzip Skia-m93-87e8842e8c-linux-Release-x64.zip && cd ..
#    ls

    #cp -rf /gw .
#    cp -rf /home/kez/CLionProjects/gw_dev/gw .
#    cd gw

#
#    rm gw -rf
    #cp -rf /home/kez/CLionProjects/gw_dev/gw .  # change this to local gw

#    cp -rf /gw .
    #git clone https://github.com/kcleal/gw && mv gw gw_build

#    cd gw_build && make && cd ..
#    cp gw_build/gw .

    make prep
    make

    ls
    pwd

fi