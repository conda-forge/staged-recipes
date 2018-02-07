if [ "$PY_VER" == "2.7" ]; then
	pip install https://pypi.python.org/packages/82/a6/e612a3a933c1e605b065e215750427550bff5ecd07f2827517d711f645d9/scrypt-0.8.3-cp27-cp27m-win_amd64.whl
elif [ "$PY_VER" == "3.5" ]; then
	pip install https://pypi.python.org/packages/ba/98/4e0044f7085597cf89683d53ca63a6db3f34ab471758359b05ed24b7a8fa/scrypt-0.8.3-cp35-cp35m-win_amd64.whl
else
	pip install https://pypi.python.org/packages/b0/5f/254f518844e541948855ebe75b47b3971214c7d5b0e24d5a14bf32dc54a3/scrypt-0.8.3-cp36-cp36m-win_amd64.whl
fi
pip install steem