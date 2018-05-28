set FFMPEG_ROOT=%LIBRARY_PREFIX%
set SDL_ROOT=%LIBRARY_PREFIX%
echo "build prefix was set to %PREFIX%"
%PREFIX%\python -m pip install --no-deps --ignore-installed .
