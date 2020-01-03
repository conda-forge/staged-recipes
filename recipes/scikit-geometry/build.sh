if [ $(uname) == Darwin ]; then
	export CXXFLAGS="$CXXFLAGS -std=c++14"
fi
python -m pip install . --no-deps --ignore-installed -vvv