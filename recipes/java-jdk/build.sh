#/bin/bash -eu

if [[ `uname` == "Linux" ]]
then
    mv lib/amd64/jli/*.so lib
    mv lib/amd64/*.so lib
    rm -r lib/amd64
    # libnio.so does not find this within jre/lib/amd64 subdirectory
    cp jre/lib/amd64/libnet.so lib

    # fonts
    mkdir -p jre/lib/fonts
    cd jre/lib/fonts
    wget --no-check-certificate http://sourceforge.net/projects/dejavu/files/dejavu/2.36/dejavu-fonts-ttf-2.36.tar.bz2
    tar -xjvpf dejavu-fonts-ttf-2.36.tar.bz2
    mv dejavu-fonts-ttf-*/ttf/* .
    rm -rf dejavu-fonts-ttf-*
    cd ../../..
fi

# mv * $PREFIX
cp -r bin $PREFIX
cp -r include $PREFIX
cp -r jre $PREFIX
cp -r lib $PREFIX
