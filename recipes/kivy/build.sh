if [ "${TRAVIS_OS_NAME}" == "linux" ]; then
  export USE_X11=1;
  export USE_GSTREAMER=1;
else
  export USE_X11=0;
  export USE_GSTREAMER=1;
fi;
USE_SDL2=1 $PYTHON -m pip install --no-deps --ignore-installed .
