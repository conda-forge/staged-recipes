:: Keep the default generator selection: forcing Ninja here collides with the
:: CMAKE_GENERATOR_PLATFORM=x64 that the Windows images export.
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
