cd pycoalescence
$PYTHON installer.py --cmake-args="-DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX}"

rm -rf __pycache__
rm -rf obj
rm -rf reference
rm -rf lib

cd ..

cp -r pycoalescence $SP_DIR
