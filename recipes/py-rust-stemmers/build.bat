@REM %PYTHON% -m pip install . -vv || goto :error

maturin build --release || goto :error
%PYTHON% -m pip install target/wheels/py_rust_stemmers-*.whl || goto :error

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1