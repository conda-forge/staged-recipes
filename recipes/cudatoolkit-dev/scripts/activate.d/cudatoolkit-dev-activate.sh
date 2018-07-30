#!/usr/bin/env bash

for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/bin/*;
do 
    link=$(basename "$f");
    ln -sf $f $CONDA_PREFIX/bin/${link};
done


for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/lib64/*;
do 
    link=$(basename "$f");
    ln -sf $f $CONDA_PREFIX/lib/${link};

done

for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/bin/*;
do 
    link=$(basename "$f");
    ln -sf $f $CONDA_PREFIX/bin/${link};

done

for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/lib64/*;
do 
    link=$(basename "$f");
    ln -sf $f $CONDA_PREFIX/lib/${link};

done

for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm/libdevice/*;
do 
    link=$(basename "$f");
    ln -sf $f $CONDA_PREFIX/lib/${link};

done

for f in $CONDA_PREFIX/pkgs/cudatoolkit-dev/include/*;
do 
    link=$(basename "$f");
    ln -sf $f $CONDA_PREFIX/include/${link};

done


ln -sf $CONDA_PREFIX/pkgs/cudatoolkit-dev/nvvm $CONDA_PREFIX/
ln -sf $CONDA_PREFIX/lib $CONDA_PREFIX/lib64
