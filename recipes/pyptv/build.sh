conda create -n pyptv_py38 python=3.8 -y
conda update -n base -c defaults conda
conda activate pyptv_py38
conda install swig=3.0.12 pyyaml cython numpy -y
pip install pyptv --index-url https://pypi.fury.io/pyptv --extra-index-url https://pypi.org/simple
$PYTHON setup.py install     # Python command to install the script.
