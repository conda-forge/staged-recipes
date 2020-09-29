setlocal EnableDelayedExpansion

pushd win

pushd c
for %%l in (cdd cdr cmd cmr csd csr) do (
    pushd "make\%%l\win32\msvc"

    nmake
    IF !ERRORLEVEL! NEQ 0 exit 1

    popd
)
copy include\*.h %LIBRARY_INC%
copy lib\*.lib %LIBRARY_LIB%
popd
