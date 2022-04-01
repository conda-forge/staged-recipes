rm -rf btrack/libs
mkdir -p btrack/{libs,obj}

make

${PYTHON} -m pip install .