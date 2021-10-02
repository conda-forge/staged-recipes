if [[ $(uname) == "Linux" ]]; then
    cd ${SRC_DIR}/build/linux/release
    export C_PLATFORM="-static -pthread"
fi

if [[ $(uname) == "Darwin" ]]; then
    cd ${SRC_DIR}/build/mac/release
    export C_PLATFORM="-pthread"
fi

export GPP=${CXX}
export PREFIX=${PREFIX}

cp ${RECIPE_DIR}/Makefile Makefile
cp ${RECIPE_DIR}/makefile_common ../..
cp ${RECIPE_DIR}/__init__.py ../../python/vina

make

cp vina ${PREFIX}/bin
cp vina_split ${PREFIX}/bin

cd ${SRC_DIR}/build/python
python setup.py build install
