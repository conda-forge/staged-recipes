# Set environment variable for C++ compiler, so it can see Cap'n Proto headers
# from capnproto package
export CPLUS_INCLUDE_PATH="$PREFIX/include"

if [ "$(uname)" = "Darwin" ]; then
    # Follow capnproto C++ library recipe settings (required by C++11)
    export MACOSX_DEPLOYMENT_TARGET="10.7"
    export CFLAGS="-stdlib=libc++ -I$PREFIX/include"
fi

python setup.py install
