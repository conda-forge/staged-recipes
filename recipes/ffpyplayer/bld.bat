set FFMPEG_ROOT=%LIBRARY_PREFIX%
set SDL_ROOT=%LIBRARY_PREFIX%
echo "Python is %PYTHON%"
%PYTHON% -m pip install --no-deps --ignore-installed .
