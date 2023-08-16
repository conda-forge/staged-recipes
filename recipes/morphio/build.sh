# Export conda_build-set variables because these are not exposed to pip otherwise
export CXXFLAGS=-I$PREFIX
# Build package via pip install
python -m pip install . -vv