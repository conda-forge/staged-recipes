pip check
turbo-turtle -h
turbo-turtle docs --print-local-path
turbo-turtle fetch --destination turbo_turtle_fetch
cd %SP_DIR%\%PKG_NAME%
REM TODO: Remove test_wrapper.py ignore when Turbo-Turtle releases a mocked cubit module
REM TODO: Remove test_fetch.py ignore when Turbo-Turtle releases a bugfix for test expectations
pytest -vvv -n 4 --ignore=_abaqus_python -m "not systemtest" --ignore=tests/test_wrappers.py --ignore=tests/test_fetch.py
