conda config --add channels salilab
conda config --set channel_priority strict
$PYTHON -m pip install . --no-deps --ignore-installed -vv
