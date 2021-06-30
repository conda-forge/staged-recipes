#echo "CXX=g++" >> make/local

echo "TBB_CXX_TYPE=gcc" >> make/local

make clean-all

make -j8 build

cp -r . $PREFIX/cmdstan
