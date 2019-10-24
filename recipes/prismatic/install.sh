cd build

make install

if [[ "$(uname)" == "Darwin" ]]; then
	rm -rf ${PREFIX}/Applications
else
	rm ${PREFIX}/bin/prismatic-gui
fi