#!/bin/bash

# install using pip from the whl file provided by pypi

if [ `uname` == Darwin ]; then
    if [ "$PY_VER" == "3.5" ]; then
        pip install https://pypi.python.org/packages/b6/86/a95d5da6ab56c5c063585e5b6bdb2b5c3e2ee4cfeb267c80e9fed1e6ac6b/scrypt-0.8.3-cp35-cp35m-macosx_10_6_intel.whl
    else
        pip install https://pypi.python.org/packages/fb/64/44461d420c0368dd77bffddda311664699eedd67a08c21ff7f36d17055de/scrypt-0.8.3-cp36-cp36m-macosx_10_6_intel.whl
    fi
fi

if [ `uname` == Linux ]; then
    if [ "$PY_VER" == "2.7" ]; then
        pip install https://github.com/holgern/py-scrypt/releases/download/v0.8.3/scrypt-0.8.3-cp27-cp27mu-linux_x86_64.whl
	elif [ "$PY_VER" == "3.5" ]; then
		pip install https://github.com/holgern/py-scrypt/releases/download/v0.8.3/scrypt-0.8.3-cp35-cp35m-linux_x86_64.whl
    else
        pip install https://github.com/holgern/py-scrypt/releases/download/v0.8.3/scrypt-0.8.3-cp36-cp36m-linux_x86_64.whl
    fi
fi

if [ `uname` == Windows ]; then
    if [ "$PY_VER" == "2.7" ]; then
        pip install https://pypi.python.org/packages/82/a6/e612a3a933c1e605b065e215750427550bff5ecd07f2827517d711f645d9/scrypt-0.8.3-cp27-cp27m-win_amd64.whl
	elif [ "$PY_VER" == "3.5" ]; then
		pip install https://pypi.python.org/packages/ba/98/4e0044f7085597cf89683d53ca63a6db3f34ab471758359b05ed24b7a8fa/scrypt-0.8.3-cp35-cp35m-win_amd64.whl
    else
        pip install https://pypi.python.org/packages/b0/5f/254f518844e541948855ebe75b47b3971214c7d5b0e24d5a14bf32dc54a3/scrypt-0.8.3-cp36-cp36m-win_amd64.whl
    fi
fi