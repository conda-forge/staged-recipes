export CXXFLAGS="$CXXFLAGS -std=c++0x"
export BOOST_PYTHON_LIB=boost_python${PY_VER//./}
export BOOST_ROOT=$PREFIX TANGO_ROOT=$PREFIX ZMQ_ROOT=$PREFIX OMNI_ROOT=$PREFIX
python -m pip install --no-binary=:all: --ignore-installed --no-deps .
