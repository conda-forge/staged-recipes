# We need to turn pip index back on because Anaconda turns
# it off for some reason.
export PIP_NO_INDEX=False
export PIP_NO_DEPENDENCIES=False
export PIP_IGNORE_INSTALLED=False

if [ "$(uname)" == "Darwin" ]; then
    pip install simpleaudio -vv --no-dependencies
fi
pip install pkgutil_resolve_name -vv --no-dependencies
pip install xarray-behave[gui] -vv --no-dependencies
