if [[ $(uname) == "Linux" ]]; then
    cd ${SRC_DIR}/build/linux/release
fi

if [[ $(uname) == "Darwin" ]]; then
    cd ${SRC_DIR}/build/mac/release
fi

export GPP=${CXX}

make

cp vina ${PREFIX}/bin
cp vina_split ${PREFIX}/bin

cd ${SRC_DIR}/build/python
python setup.py build install
