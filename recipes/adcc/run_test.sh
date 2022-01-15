# install pyscf
pip install pyscf
python -c "import pyscf"
# run adcc smoke tests
pytest --pyargs adcc -v