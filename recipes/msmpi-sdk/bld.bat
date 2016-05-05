IF "%ARCH%" == "64" (
    set "x86_DIR= (x86)"
    set "ARCH_DIR=x64"
) else (
    set "ARCH_DIR=x86"
)

msiexec /i %CD%\msmpisdk.msi /qb TARGETDIR=%CD%\sdk

copy "C:\Program Files%x86_DIR%\Microsoft SDKs\MPI\Lib\%ARCH_DIR%\*" %LIBRARY_LIB%\
copy "C:\Program Files%x86_DIR%\Microsoft SDKs\MPI\Include\*" %LIBRARY_INC%\
copy "C:\Program Files%x86_DIR%\Microsoft SDKs\MPI\Include\%ARCH_DIR%\*" %LIBRARY_INC%\
copy "C:\Program Files%x86_DIR%\Microsoft SDKs\MPI\License\license_sdk.rtf" %SRC_DIR%\
