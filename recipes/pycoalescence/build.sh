cd pycoalescence/lib
$PYTHON installer.py --cmake-args="-DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX}"

cd ..

rm -rf __pycache__
rm -rf obj
rm -rf reference
rm -rf lib

cd ..

cp -r pycoalescence $SP_DIR
