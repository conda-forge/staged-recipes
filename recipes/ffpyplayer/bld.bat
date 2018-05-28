set FFMPEG_ROOT=%LIBRARY_PREFIX%
set SDL_ROOT=%LIBRARY_PREFIX%
set PATH=%PREFIX%;%PATH%
python -m pip install --no-deps --ignore-installed .
