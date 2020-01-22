export CFLAGS="${CFLAGS} -I/usr/include"
export CXXFLAGS="${CXXFLAGS} -I/usr/include"

rm pyproject.toml
pyhton -m pip install . -vv

