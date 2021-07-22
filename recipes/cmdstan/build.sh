mkdir -p $PREFIX/bin
cp -r . $PREFIX/bin/cmdstan

cd $PREFIX/bin/cmdstan

echo "TBB_CXX_TYPE=${c_compiler}"  >> make/local
#echo "TBB_INTERFACE_NEW=true" >> make/local
echo "TBB_INC=${PREFIX}/include/" >> make/local
echo "TBB_LIB=${PREFIX}/lib/" >> make/local
echo "PRECOMPILED_HEADERS=false" >> make/local

cat make/local

make clean-all

make build -j${CPU_COUNT}


echo "CMDSTAN=${PREFIX}/bin/cmdstan" > "${RECIPE_DIR}/activate.sh"
# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
