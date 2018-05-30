if [ "${TRAVIS_OS_NAME}" == "linux" ]; then
  # ln -s /usr/lib/x86_64-linux-gnu/libGL.so $PREFIX/lib/libGL.so;
  export USE_GSTREAMER=1;
else
  export USE_GSTREAMER=0;
fi;
USE_X11=1 USE_SDL2=1 $PYTHON -m pip install --no-deps --ignore-installed .
