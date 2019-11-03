:: Create an empty library for msvcrt??? since CygwinCCompiler seems to
:: think that linking to that is a good idea (it is not).
if "%CONDA_PY%" == "27" (
  ar cru %PREFIX%\libs\libmsvcr90.dll.a
) else (
  if "%CONDA_PY%" == "34" (
    ar cru %PREFIX%\libs\libmsvcr120.dll.a
  ) else (
    ar cru %PREFIX%\libs\libmsvcr140.dll.a
  )
)
gendef.exe %PREFIX%\python%CONDA_PY%.dll - > python%CONDA_PY%.def
if errorlevel 1 exit 1
dlltool.exe -d python%CONDA_PY%.def -l %PREFIX%\libs\libpython%CONDA_PY%.dll.a
if errorlevel 1 exit 1
if not exist %PREFIX%\Lib\distutils\ mkdir %PREFIX%\Lib\distutils\
if errorlevel 1 exit 1
echo [build]           > %PREFIX%\Lib\distutils\distutils.cfg
if errorlevel 1 exit 1
echo compiler=mingw32 >> %PREFIX%\Lib\distutils\distutils.cfg
if errorlevel 1 exit 1
