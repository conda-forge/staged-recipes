rem Safe-guard: Only delete temporary file if we really are sure it is
rem temporary.
if "%CLANG_MAKEVARS%" == "%R_MAKEVARS_SITE%" (
  del %CLANG_MAKEVARS%
)

if NOT [%R_MAKEVARS_SITE_1] == [] (
  set "R_MAKEVARS_SITE=%R_MAKEVARS_SITE_1%
)

