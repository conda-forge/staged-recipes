#conda install pytorch torchvision cudatoolkit=10.0 -c pytorch


# successful installation of intel c++ compiler is required
# activate intel c++ compiler environment
# source ~/intel/parallel_studio_xe_2019.3.062/bin/psxevars.sh

cd ./src
make
cp libtrefide.so $CONDA_PREFIX/lib/
cp trefide.h $CONDA_PREFIX/include/

cp ./glmgen/lib/libglmgen.so $CONDA_PREFIX/lib/
cp ./glmgen/include/glmgen.h $CONDA_PREFIX/include/
cp ./proxtv/libproxtv.so $CONDA_PREFIX/lib/
cp ./proxtv/proxtv.h $CONDA_PREFIX/include/
cd ../

$PYTHON setup.py install --single-version-externally-managed --record=record.txt  # Python command to install the script.
