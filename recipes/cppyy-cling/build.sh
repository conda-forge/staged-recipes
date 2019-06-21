cd cling
export STDCXX=17
export VERBOSE=1
python setup.py egg_info
python create_src_directory.py
python -m pip install . --no-deps -vv
