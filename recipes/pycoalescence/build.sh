cd pycoalescence/lib
cmake -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX} .

cd ..

rm -rf __pycache__
rm -rf obj
rm -rf reference
rm -rf lib

cd ..

cp -r pycoalescence $SP_DIR
