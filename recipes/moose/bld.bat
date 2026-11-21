@echo on

REM Build and install via the meson-python backend
"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
