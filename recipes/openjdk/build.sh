#/bin/bash -eu

if [[ `uname` == "Linux" ]]
then
    mv lib/amd64/jli/*.so lib
    mv lib/amd64/*.so lib
    rm -r lib/amd64
fi

cp -r bin $PREFIX
cp -r include $PREFIX
cp -r jre $PREFIX
cp -r lib $PREFIX

for action in activate deactivate
do
    dir=$PREFIX/etc/conda/$action.d
    mkdir -p $dir
    cp $RECIPE_DIR/scripts/$action.sh $dir/java_home.sh
done
