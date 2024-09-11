turbo-turtle -h
turbo-turtle fetch --destination turbo_turtle_fetch
cd %SP_DIR%\%PKG_NAME%
REM TODO: Remove test_wrapper.py ignore when Turbo-Turtle releases a mocked cubit module
pytest -vvv -n 4 --ignore=_abaqus_python -m "not systemtest" --ignore=tests/test_wrappers.py
