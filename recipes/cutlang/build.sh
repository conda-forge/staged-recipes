# Temp
wget -O LICENSE https://raw.githubusercontent.com/unelg/CutLang/master/LICENSE
cp LICENSE $PREFIX/bin/cutlang/LICENSE
# Temp

BUILD_PREFIX=$PREFIX

mkdir -p $PREFIX/bin

cd CLA
make clean
cp -R ../ $PREFIX/bin/cutlang

rm -rf $PREFIX/bin/cutlang/.github
rm -rf $PREFIX/bin/cutlang/.git

cd $PREFIX/bin/cutlang/CLA

make

echo "build.sh done"

for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${PREFIX}/bin/cutlang/conda_${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
    cp "${PREFIX}/bin/cutlang/root_unset_for_conda.sh" "${PREFIX}/etc/conda/activate.d/__root_unset_for_conda.sh"
done
