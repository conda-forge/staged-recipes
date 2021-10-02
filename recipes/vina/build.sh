if [[ $(uname) == "Linux" ]]; then
    cd ${SRC_DIR}/build/linux/release
<<<<<<< HEAD
    export C_PLATFORM="-static -pthread"
#    cp ${RECIPE_DIR}/Makefile_linux Makefile
=======
    C_PLATFORM="-static -pthread"
>>>>>>> a08fa9687150aae5e1516c7202478f47d56b25d9
fi

if [[ $(uname) == "Darwin" ]]; then
    cd ${SRC_DIR}/build/mac/release
<<<<<<< HEAD
    export C_PLATFORM="-pthread"
#    cp ${RECIPE_DIR}/Makefile_mac Makefile
=======
    C_PLATFORM="-pthread"
>>>>>>> a08fa9687150aae5e1516c7202478f47d56b25d9
fi

cp ${RECIPE_DIR}/Makefile Makefile
cp ${RECIPE_DIR}/makefile_common ../..
cp ${RECIPE_DIR}/__init__.py ../../python/vina

<<<<<<< HEAD
make #C_PLATFORM=${C_PLATFORM}
=======
make
>>>>>>> a08fa9687150aae5e1516c7202478f47d56b25d9

cp vina ${PREFIX}/bin
cp vina_split ${PREFIX}/bin

cd ${SRC_DIR}/build/python
python setup.py build install
