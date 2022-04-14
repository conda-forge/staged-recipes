conda create -n pyptv_py39 python=3.9 -y
conda update -n base -c defaults conda
conda activate pyptv_py39
conda install swig pyyaml cython numpy -y
pip install optv --index-url https://pypi.fury.io/pyptv
pip install git+https://github.com/enthought/enable
$PYTHON setup.py install     # Python command to install the script.