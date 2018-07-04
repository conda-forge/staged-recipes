set USE_GSTREAMER=0
set USE_SDL2=1
set KIVY_SDL2_PATH=%LIBRARY_INC%\SDL2
%PYTHON% -m pip install --verbose --no-deps --ignore-installed .
