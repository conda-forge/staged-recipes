cp $RECIPE_DIR/conda.rc .
cp $RECIPE_DIR/patch.txt .
patch futile/flib/utils.c patch.txt 
mkdir build
cd build
python ../Installer.py -y autogen
python ../Installer.py -y build -f ../conda.rc
