pushd lib

for %%libdir in (cdd cdr cmd cmr csd csr) do (
    pushd "make\%%libdir\win32\msvc"

    nmake
    IF %ERRORLEVEL% NEQ 0 exit 1

    popd
)
popd

pushd py
%PYTHON% setup.py build --compiler msvc
%PYTHON% setup.py install --prefix=%PREFIX%
