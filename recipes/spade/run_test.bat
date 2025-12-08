set system_test_directory=%CD%
cd %SP_DIR%\%PKG_NAME%
pytest -vvv -n 4 -m "not require_third_party" --system-test-dir=%system_test_directory%
