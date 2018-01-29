#!/bin/sh

# Remove __FILE__ lines in utils file.
sed -i -e "s:__FILE__:'fdf/utils.F90':g" Src/fdf/utils.F90

# Use the default utilities, for now.
cd Obj
../Src/obj_setup.sh

# Create arch.make file by replacing the prefix directory
sed -e "s:__SIESTA_PREFIX__:$PREFIX:g" $RECIPE_DIR/arch.make.SEQ > ./arch.make

function mkcp {
    local target=$1
    shift
    local exe=$target
    if [ $# -ge 1 ]; then
	exe=$1
	shift
    fi
    make $target
    cp $target $PREFIX/bin/$exe
    make clean
}

mkcp siesta
mkcp transiesta

cd ../Util/Bands
mkcp new.gnubands
mkcp eigfat2plot
mkcp gnubands

cd ../Eig2DOS
mkcp Eig2DOS

cd ../COOP
mkcp mprop
mkcp fat

cd ../Denchar/Src
mkcp denchar

cd ../../TBTrans_rep
mkcp tbtrans

cd ../TBTrans
mkcp tbtrans tbtrans_old

cd ../Vibra/Src
mkcp fcbuild
mkcp vibra

